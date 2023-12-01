#!/bin/bash
#SBATCH --job-name=pluc_quast
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
conda activate quast520

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="quast"

# contigs and scaffolds
CONTIG="pluc_hic_genome.fa"
SCAFFOLD="pluc_hic_genome.3ddna.clean.nocontamination.renamed.fa"
#SCAFFOLD="pluc_hic_genome.3ddna.fa"

CONTIGDIR="$STORAGE/current_draft/$CONTIG"
SCAFFOLDDIR="$STORAGE/current_draft/$SCAFFOLD"
#SCAFFOLDDIR="$STORAGE/3ddna/finalize/$SCAFFOLD"
#SCAFFOLDDIR="$STORAGE/current_draft/$SCAFFOLD"

# hifi reads
FILE1="m64047_220829_191921.ccs.filt.fastq.gz"
FILE2="m64047_220831_061814.ccs.filt.fastq.gz"

FILE1DIR="$STORAGE/hifiadapterfilt/$FILE1"
FILE2DIR="$STORAGE/hifiadapterfilt/$FILE2"

# outdir
OUT="pluc_quast_final"

PROC=32

# copy data
mkdir -p $SCRATCH/$PROGRAM
rsync $CONTIGDIR $SCRATCH/$PROGRAM/.
rsync $SCAFFOLDDIR $SCRATCH/$PROGRAM/.
rsync $FILE1DIR $SCRATCH/$PROGRAM/.
rsync $FILE2DIR $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run quast
quast.py $CONTIG $SCAFFOLD -o $OUT -t $PROC --pacbio $FILE1 --pacbio $FILE2 --large

rm $SCRATCH/$PROGRAM/$CONTIG
rm $SCRATCH/$PROGRAM/$SCAFFOLD
rm $SCRATCH/$PROGRAM/$FILE1
rm $SCRATCH/$PROGRAM/$FILE2

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
