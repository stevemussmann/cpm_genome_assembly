#!/bin/bash
#SBATCH --job-name=pluc_hic_trimgalore
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

source ~/miniconda3/etc/profile.d/conda.sh
conda activate trimgalore067

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="trimgalore_hic"

FILT="$STORAGE/raw/hic"

PROC=32

mkdir -p $SCRATCH/$PROGRAM/trimmed

rsync $FILT/Fish_HiC_S1_L001_R*_001.fastq.gz $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run Trimgalore
for file1 in *R1_001.fastq.gz
do
	file2="${file1%R1_001.fastq.gz}R2_001.fastq.gz"
	trim_galore -j 4 --paired --retain_unpaired --output_dir $SCRATCH/$PROGRAM/trimmed $file1 $file2
done

mkdir $STORAGE/$PROGRAM
rm Fish_HiC_S1_L001_R*_001.fastq.gz
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
