#!/bin/bash
#SBATCH --job-name=pluc_filter
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&768gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --exclusive
#SBATCH --time=480:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

#module purge
#module load os/el7 intel/14.0.3 openmpi/1.8.8 python/2.7.11 mkl/14.0.3 java/sunjdk_1.8.0_72 boost/1.60.0 gsl/2.4-gcc

#source ~/miniconda3/etc/profile.d/conda.sh
#conda activate rcorrector105


STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="FilterUncorrectablePEfastq"

COR="$STORAGE/rcorrector/out"

PROC=32

mkdir -p $SCRATCH/$PROGRAM/

rsync $COR/*.cor.fq $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run rcorrector
for file1 in Pluc_transcriptome_*_R1_001.cor.fq
do
	file2=${file1%_R1_001.cor.fq}_R2_001.cor.fq
	FilterUncorrectablePEfastq.pl -f $file1 -F $file2
	rm $file1
	rm $file2
done

gzip *.fq

mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
