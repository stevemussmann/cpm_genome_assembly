#!/bin/bash
#SBATCH --job-name=pluc_hifiadapterfilt
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&768gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --exclusive
#SBATCH --time=240:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
source ~/miniconda3/etc/profile.d/conda.sh
conda activate hifiadapterfilt

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"

PROC=32

FILE1="m64047_220829_191921.ccs.fastq.gz"
FILE2="m64047_220831_061814.ccs.fastq.gz"

PROGRAM="hifiadapterfilt"

mkdir -p $SCRATCH/$PROGRAM

rsync $STORAGE/raw/pacbio/*.fastq.gz $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

export PATH=$PATH:/home/mussmann/local/src/HiFiAdapterFilt/
export PATH=$PATH:/home/mussmann/local/src/HiFiAdapterFilt/DB

bash pbadapterfilt.sh -t $PROC

rm $FILE1
rm $FILE2

rsync -r $SCRATCH/$PROGRAM $STORAGE/$PROGRAM/.

#rm -r $SCRATCH/$PROGRAM/

exit
