#!/bin/bash
#SBATCH --job-name=pluc_juicer
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&768gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --exclusive
#SBATCH --time=240:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
source ~/miniconda3/etc/profile.d/conda.sh

## make a custom conda environment using the command in the next line. juicer_tools is somewhat picky about java version but 8.0.112 seems to work fine
#conda create -n juicer -c conda-forge -c bioconda python coreutils bioawk java-jdk=8.0.112 bwa

conda activate juicer

# location of scripts
JUICERDIR="/home/mussmann/local/src/juicer/juicer-1.6"
SCRIPTSDIR="$JUICERDIR/misc"
PIPELINEDIR="$JUICERDIR/CPU"

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="juicer"

# main directory
MD="01_JuicerSetup"

# subdirectories
FASTQDIR="$SCRATCH/$PROGRAM/$MD/fastq"
REFDIR="$SCRATCH/$PROGRAM/$MD/references"
REDIR="$SCRATCH/$PROGRAM/$MD/restriction_sites"
SPLITDIR="$SCRATCH/$PROGRAM/$MD/splits"

# copy juicer scripts
# even though juicer.sh lets you set path to the scripts, it still looks for the subdirectory scripts/common within the directory you specify
# also make sure the latest juicer jar file is in the 'common' folder.
# also make sure the juicer_tools file has been edited so it calls your juicer tools version (e.g., juicer_tools_1.22.01.jar) rather than juicer_tools.jar (see last line of juicer_tools file)
mkdir -p $SCRATCH/$PROGRAM/$MD/scripts/
cp -r $PIPELINEDIR/common $SCRATCH/$PROGRAM/$MD/scripts/.

# make directories
mkdir -p $FASTQDIR
mkdir -p $REFDIR
mkdir -p $REDIR
mkdir -p $SPLITDIR

#file names for copying and renaming
FASTA="pluc_hic_genome.fa"
HIC1="Fish_HiC_S1_L001_R1_001_val_1.fq.gz"
HIC2="Fish_HiC_S1_L001_R2_001_val_2.fq.gz"
NEWHIC1="HiC_R1.fastq.gz"
NEWHIC2="HiC_R2.fastq.gz"
HIC1DIR="$STORAGE/trimgalore_hic/trimmed/$HIC1"
HIC2DIR="$STORAGE/trimgalore_hic/trimmed/$HIC2"

GENOME="$STORAGE/current_draft/$FASTA"

PROC=32

# copy the contig fasta files
echo "copying contig fasta file"
rsync $GENOME $REFDIR/.

# copy the hic files
echo "copying hic fastq files"
rsync $HIC1DIR $FASTQDIR/$NEWHIC1
rsync $HIC2DIR $FASTQDIR/$NEWHIC2

# unzip fastq files
echo "unzipping hic fastq files"
cd $FASTQDIR
gunzip *.gz

# split the fastq files
cd $SPLITDIR
echo "splitting fastq files (processes are backgrounded and will continue as the script moves to indexing)"
split -a 3 -l 90000000 -d --additional-suffix=_R2.fastq $FASTQDIR/${NEWHIC1%.gz} &
split -a 3 -l 90000000 -d --additional-suffix=_R1.fastq $FASTQDIR/${NEWHIC2%.gz} &

# bwa index the contigs
echo "indexing contigs"
cd $REFDIR
bwa index $FASTA

# find restriction enzyme sites
echo "finding restriction cut sites"
cd $REDIR
python $SCRIPTSDIR/generate_site_positions.py DpnII $FASTA $REFDIR/$FASTA

# make chromosome sizes file
echo "printing contig sizes to chrom.sizes"
bioawk -c fastx '{print $name"\t"length($seq)}' $REFDIR/$FASTA > $SCRATCH/$PROGRAM/$MD/chrom.sizes

# run juicer
echo "running juicer pipeline"
$PIPELINEDIR/juicer.sh -d $SCRATCH/$PROGRAM/$MD -p $SCRATCH/$PROGRAM/$MD/chrom.sizes -s DpnII -z $REFDIR/$FASTA -D $SCRATCH/$PROGRAM/$MD -y $REDIR/${FASTA}_DpnII.txt -g $FASTA -t $PROC

# cleanup
echo "deleting files after juicer pipeline run"
rm $REFDIR/$FASTA #contig fasta
rm $REFDIR/${FASTA}.* #contig index
rm $FASTQDIR/${NEWHIC1%.gz} #HiC read 1
rm $FASTQDIR/${NEWHIC2%.gz} #HiC read 2
rm $SPLITDIR/x0*.fastq #split HiC files

# archive data
echo "copying data to storage"
mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
