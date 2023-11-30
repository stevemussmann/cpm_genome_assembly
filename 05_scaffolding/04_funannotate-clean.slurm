#!/bin/bash
#SBATCH --job-name=pluc_funannotate-clean
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&256gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --exclusive
#SBATCH --time=24:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
source ~/miniconda3/etc/profile.d/conda.sh
conda activate funannotate

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="funannotate/clean"

# list file names and parameters
FASTA="pluc_hic_genome.3ddna.fa"
CLEAN="pluc_hic_genome.3ddna.clean.fa"
SORTED="${CLEAN%.fa}.sorted.fa"
PROC=16

# make scratch directory
mkdir -p $SCRATCH/$PROGRAM

# copy files
rsync $STORAGE/current_draft/$FASTA $SCRATCH/$PROGRAM/.

# change directories
cd $SCRATCH/$PROGRAM

# run funannotate clean
funannotate clean -i $FASTA -o $CLEAN --minlen 1000

# funannotate sort
funannotate sort -i $CLEAN -b scaffold -o $SORTED

# copy results to storage
mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
