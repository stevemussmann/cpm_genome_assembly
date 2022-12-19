#!/bin/bash
#SBATCH --job-name=pluc_rcorrector
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&768gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --exclusive
#SBATCH --time=480:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
#module load os/el7 intel/14.0.3 openmpi/1.8.8 python/2.7.11 mkl/14.0.3 java/sunjdk_1.8.0_72 boost/1.60.0 gsl/2.4-gcc

source ~/miniconda3/etc/profile.d/conda.sh
conda activate rcorrector105


STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="rcorrector"

RAW="$STORAGE/raw/transcriptome"

PROC=32

mkdir -p $SCRATCH/$PROGRAM/out

rsync $RAW/*.fastq.gz $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

gunzip *.gz

left="Pluc_transcriptome_01_kidney_S1_L002_R1_001.fastq,Pluc_transcriptome_03_gill_S2_L002_R1_001.fastq,Pluc_transcriptome_05_heart_S3_L002_R1_001.fastq,Pluc_transcriptome_06_gall-bladder_S4_L002_R1_001.fastq,Pluc_transcriptome_08_eye_S5_L002_R1_001.fastq,Pluc_transcriptome_09_brain_S6_L002_R1_001.fastq,Pluc_transcriptome_12_spleen_S7_L002_R1_001.fastq,Pluc_transcriptome_13_liver_S8_L002_R1_001.fastq,Pluc_transcriptome_15_skin_S9_L002_R1_001.fastq,Pluc_transcriptome_17_testes_S10_L002_R1_001.fastq,Pluc_transcriptome_19_muscle_S11_L002_R1_001.fastq"
right="Pluc_transcriptome_01_kidney_S1_L002_R2_001.fastq,Pluc_transcriptome_03_gill_S2_L002_R2_001.fastq,Pluc_transcriptome_05_heart_S3_L002_R2_001.fastq,Pluc_transcriptome_06_gall-bladder_S4_L002_R2_001.fastq,Pluc_transcriptome_08_eye_S5_L002_R2_001.fastq,Pluc_transcriptome_09_brain_S6_L002_R2_001.fastq,Pluc_transcriptome_12_spleen_S7_L002_R2_001.fastq,Pluc_transcriptome_13_liver_S8_L002_R2_001.fastq,Pluc_transcriptome_15_skin_S9_L002_R2_001.fastq,Pluc_transcriptome_17_testes_S10_L002_R2_001.fastq,Pluc_transcriptome_19_muscle_S11_L002_R2_001.fastq"

# run rcorrector
run_rcorrector.pl -1 $left -2 $right -t $PROC -od $SCRATCH/$PROGRAM/out

rm *.fastq

mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
