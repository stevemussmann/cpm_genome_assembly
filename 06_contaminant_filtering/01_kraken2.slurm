#!/bin/bash
#SBATCH --job-name=pluc_kraken2
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
conda activate kraken212

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="kraken2"

FASTA="pluc_hic_genome.3ddna.pre-kraken2.fa"

# kraken2 PlusPFP refseq index downloaded from https://benlangmead.github.io/aws-indexes/k2 because the kraken2 download tool is perpetually broken.
DB="/storage/mussmann/k2_pluspfp_20220607"

GENOME="$STORAGE/current_draft/$FASTA"

PROC=16

mkdir -p $SCRATCH/$PROGRAM

rsync $GENOME $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run kraken2
kraken2 --threads $PROC --db $DB $FASTA --classified-out pluc_classified.fa \
	--unclassified-out pluc_unclassified.fa --report pluc_report.txt

rm $SCRATCH/$PROGRAM/$FASTA

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
