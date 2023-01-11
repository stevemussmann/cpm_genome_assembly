#!/bin/bash
#SBATCH --job-name=pluc_p_rna_scaffolder
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
conda activate p_rna_scaffolder

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
SUBMIT=$SLURM_SUBMIT_DIR
PROGRAM="p_rna_scaffolder"
PROGDIR="/home/mussmann/local/src/P_RNA_scaffolder/"

SCRIPT="P_RNA_scaffolder.sh"

FASTA="scaffolds_FINAL.fasta"

GENOME="$STORAGE/salsa/pluc_scaffolds/$FASTA"
RAW="$STORAGE/prinseq"

# new file names
R1="Pluc_transcriptome_R1.fq.gz"
R2="Pluc_transcriptome_R2.fq.gz"
INDEX=pluc_scaff
SAM=pluc_trans.sam

PROC=16

mkdir -p $SCRATCH/$PROGRAM

rsync $RAW/*.fastq.gz $SCRATCH/$PROGRAM/.
rsync $GENOME $SCRATCH/$PROGRAM/.
rsync $SUBMIT/$SCRIPT $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

#concatenate transcriptome reads
zcat Pluc_transcriptome_*R1*.fastq.gz | gzip > $R1
zcat Pluc_transcriptome_*R2*.fastq.gz | gzip > $R2
rm *.fastq.gz

# index with hisat
hisat2-build $FASTA $INDEX

# align with hisat2
hisat2 -x $INDEX -1 $R1 -2 $R2 -k 3 -p $PROC --pen-noncansplice 1000000 -S $SAM

# run p_rna_scaffold
./$SCRIPT -d $PROGDIR -i $SAM -j $FASTA -F $R1 -R $R2

rm $SCRATCH/$PROGRAM/$FASTA
rm $R1
rm $R2

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
