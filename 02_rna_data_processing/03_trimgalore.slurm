#!/bin/bash
#SBATCH --job-name=pluc_trimgalore
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
PROGRAM="trimgalore"

FILT="$STORAGE/FilterUncorrectablePEfastq"

PROC=32

mkdir -p $SCRATCH/$PROGRAM/trimmed

rsync $FILT/*.kept.fq.gz $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run Trimgalore
for file1 in *R1_001.cor.kept.fq.gz
do
	file2="${file1%R1_001.cor.kept.fq.gz}R2_001.cor.kept.fq.gz"
	trim_galore -j 4 --paired --retain_unpaired --output_dir $SCRATCH/$PROGRAM/trimmed $file1 $file2
done

mkdir $STORAGE/$PROGRAM
rm *.cor.kept.fq.gz
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
