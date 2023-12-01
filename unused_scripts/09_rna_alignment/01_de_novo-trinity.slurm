#!/bin/bash
#SBATCH --job-name=pluc_trinity
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
conda activate trinity2132

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="trinity"

RAW="$STORAGE/silva_align"
SF="sample_file.txt"

GENOME="$STORAGE/current_draft/$FASTA"

PROC=32

mkdir -p $SCRATCH/$PROGRAM

rsync $RAW/*.fastq.gz $SCRATCH/$PROGRAM/.
cp $SLURM_SUBMIT_DIR/$SF $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run Trinity
Trinity --trimmomatic --seqType fq --max_memory 700G --samples_file $SF --SS_lib_type RF --CPU $PROC

mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
