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
PROGRAM="busco/3ddna/vertebrata"

FASTA="pluc_hic_genome.3ddna.clean.nocontamination.renamed.fa"

GENOME="$STORAGE/current_draft/$FASTA"

OUT="pluc_busco"

PROC=16

mkdir -p $SCRATCH/$PROGRAM

rsync $GENOME $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run busco
busco -c $PROC -m genome -i $GENOME -o $OUT -l vertebrata_odb10

rm $SCRATCH/$PROGRAM/$GENOME

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
