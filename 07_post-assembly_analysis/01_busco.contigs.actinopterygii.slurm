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
conda activate busco542

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="busco/contigs/actinopterygii"

FASTA="pluc_hic_genome.fa"

GENOME="$STORAGE/current_draft/$FASTA"

OUT="pluc_busco"

PROC=16

mkdir -p $SCRATCH/$PROGRAM

rsync $GENOME $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run busco
busco -c $PROC -m genome -i $GENOME -o $OUT -l actinopterygii_odb10

rm $SCRATCH/$PROGRAM/$FASTA

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
