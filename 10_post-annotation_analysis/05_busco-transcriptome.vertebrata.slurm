#!/bin/bash
#SBATCH --job-name=pluc_busco
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&256gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --exclusive
#SBATCH --time=240:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
source ~/miniconda3/etc/profile.d/conda.sh
conda activate busco550

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="busco_transcriptome/vertebrata"

TRANSDIR="$STORAGE/orthofinder/primary_transcripts"
FASTA="Ptychocheilus_lucius.proteins.faa"
OUT="pluc_transcriptome"

PROC=16

mkdir -p $SCRATCH/$PROGRAM

rsync $TRANSDIR/$FASTA $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run busco
busco -c $PROC -m protein -i $FASTA -o $OUT -l vertebrata_odb10

rm $SCRATCH/$PROGRAM/$FASTA

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
