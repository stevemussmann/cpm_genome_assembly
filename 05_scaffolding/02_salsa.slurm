#!/bin/bash
#SBATCH --job-name=pluc_salsa
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

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="salsa"

#INPUTS
FASTA="pluc_hic_genome.fa"
BAM="Pluc_HiC_rep1.bam"

GENOME="$STORAGE/current_draft/$FASTA"
HIC="$STORAGE/arima/rep/$BAM"

#OUTPUTS
BED="pluc_hic_alignment.bed"
FAI="$FASTA.fai"

PROC=16

mkdir -p $SCRATCH/$PROGRAM

rsync $GENOME $SCRATCH/$PROGRAM/.
rsync $HIC $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

#convert to bed and sort for salsa input 
conda activate bedtools2300
bamToBed -i $BAM > $BED
sort --parallel=$PROC -k 4 $BED > tmp && mv tmp $BED

#index contigs for salsa input
conda deactivate
conda activate samtools1151
samtools faidx $FASTA

# run salsa
conda deactivate
conda activate salsa23
run_pipeline.py -a $FASTA -l $FAI -b $BED -e GATC -o pluc_scaffolds -m yes -i 30

rm $SCRATCH/$PROGRAM/$FASTA
rm $SCRATCH/$PROGRAM/$BAM
rm $SCRATCH/$PROGRAM/$BED

mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
