#!/bin/bash
#SBATCH --job-name=pluc_interproscan
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&256gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --exclusive
#SBATCH --time=48:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

#module purge

PROC=16

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
FASTA="braker.aa" # faa file from braker
DATA="$STORAGE/braker/braker/$FASTA"
PROGRAM="interproscan"
BASE="pluc_ips" # basename for interproscan

# copy data
mkdir -p $SCRATCH/$PROGRAM
cp $DATA $SCRATCH/$PROGRAM/.

# change directories
cd $SCRATCH/$PROGRAM

# strip asterisks from input fasta
sed -i 's/\*//g' $FASTA

# run interproscan
interproscan-5.65-97.sh -b $BASE --cpu $PROC --goterms --input $FASTA --pathways --verbose

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit

