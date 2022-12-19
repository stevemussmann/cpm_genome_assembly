#!/bin/bash
#SBATCH --job-name=pluc_meryl
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
#conda package was for and old version - had to do a manual install of version 1.3

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="meryl"
HISTOGRAM="pluc.histogram.txt"
KMER=32

HIFI1="m64047_220829_191921.ccs.filt.fastq.gz"
HIFI2="m64047_220831_061814.ccs.filt.fastq.gz"

HIFI1DIR="$STORAGE/hifiadapterfilt/$HIFI1"
HIFI2DIR="$STORAGE/hifiadapterfilt/$HIFI2"

PROC=16

mkdir -p $SCRATCH/$PROGRAM

rsync $HIFI1DIR $SCRATCH/$PROGRAM/.
rsync $HIFI2DIR $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run meryl
meryl threads=$PROC union-sum output pluc.meryl [count k=$KMER $HIFI1 output hifi1.meryl] [count k=$KMER $HIFI2 output hifi2.meryl]

# make histogram
meryl histogram pluc.meryl > $HISTOGRAM

# run genomescope2
conda deactivate
conda activate genomescope2
mkdir genomescope2

genomescope2 -i $HISTOGRAM -o genomescope2/ -k $KMER

rm $HIFI1
rm $HIFI2

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
