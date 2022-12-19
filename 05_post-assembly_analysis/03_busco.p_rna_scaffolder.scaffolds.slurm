#!/bin/bash
#SBATCH --job-name=pluc_busco_hifiasm_ccs.20_rna.scaffolds
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
SCRATCH="/scratch/$SLURM_JOB_ID"

# hifiasm or hicanu
PROG="hifiasm"

# CCS level: 0, 10, 20
CCS=20

# scaffolds or contigs
TYPE="rna.scaffolds"

PROGRAM="busco/$PROG/ccs/$CCS/$TYPE"

FASTA="pluc_hic_genome.salsa.p_rna.fa"

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
