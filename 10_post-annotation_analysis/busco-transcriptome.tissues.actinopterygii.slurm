#!/bin/bash
#SBATCH --job-name=pluc_busco
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&768gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --exclusive
#SBATCH --time=240:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
source ~/miniconda3/etc/profile.d/conda.sh
conda activate busco550

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="busco_transcriptome_tissues/actinopterygii"

TRANSDIR="$STORAGE/gffread"

PROC=32

mkdir -p $SCRATCH/$PROGRAM

rsync $TRANSDIR/*.longest.fasta $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

# run busco
for file in *.longest.fasta
do
	busco -c $PROC -m transcriptome -i $file -o ${file%.longest.fasta} -l actinopterygii_odb10
done

rm $SCRATCH/$PROGRAM/*.longest.fasta

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
