#!/bin/bash
#SBATCH --job-name=pluc_3ddna
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
conda activate 3d-dna201008

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="3ddna/firstrun"
mkdir -p $SCRATCH/$PROGRAM

#file names for copying and renaming
FASTA="pluc_hic_genome.fa"
GENOME="$STORAGE/current_draft/$FASTA"

HIC="merged_nodups.txt"
ALIGN="$STORAGE/juicer/01_JuicerSetup/aligned/$HIC"

PROC=32

# copy the contig fasta files
echo "copying contig fasta file"
rsync $GENOME $SCRATCH/$PROGRAM/.

# copy the hic files
echo "copying hic fastq files"
rsync $ALIGN $SCRATCH/$PROGRAM/.

# wrap original fasta file - makes some steps significantly faster
cd $SCRATCH/$PROGRAM
wget https://raw.githubusercontent.com/aidenlab/3d-dna/master/utils/wrap-fasta-sequence.awk
awk -f wrap-fasta-sequence.awk $FASTA > tmp
mv tmp $FASTA

# run 3ddna
echo "running 3ddna"
3d-dna $SCRATCH/$PROGRAM/$FASTA $SCRATCH/$PROGRAM/$HIC

# cleanup
echo "deleting files after juicer pipeline run"
rm $SCRATCH/$PROGRAM/$FASTA #contig fasta
rm $SCRATCH/$PROGRAM/$HIC # HiC file

# archive data
echo "copying data to storage"
mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
