#!/bin/bash
#SBATCH --job-name=pluc_blast
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&768gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --exclusive
#SBATCH --time=24:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge

source ~/miniconda3/etc/profile.d/conda.sh
conda activate blast2130

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="blast_rm_swissprot"

FASTA="pluc-families.fa"
RMDIR="$STORAGE/repeatmodeler"
DB="/storage/mussmann/sprot_blastdb/2023-11-30/uniprot_sprot.fasta"

OUT="${FASTA}.matches.tsv"

PROC=32

mkdir -p $SCRATCH/$PROGRAM

rsync $RMDIR/$FASTA $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run BLAST
blastx -query $FASTA -db $DB -out $OUT -evalue 0.0001 -num_threads $PROC -max_target_seqs 1 -outfmt 6

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
