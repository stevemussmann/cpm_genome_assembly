#!/bin/bash
#SBATCH --job-name=pluc_repeatmodeler
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
conda activate repeatmodeler203

PROC=32
PA=$(($PROC/4))

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="repeatmodeler"

FASTA="pluc_hic_genome.3ddna.clean.nocontamination.renamed.fa"
DB="pluc"

GENOME="$STORAGE/current_draft/$FASTA"

mkdir -p $SCRATCH/$PROGRAM

rsync $GENOME $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

BuildDatabase -name $DB $FASTA

RepeatModeler -database $DB -pa $PA -LTRStruct

rm $SCRATCH/$PROGRAM/$FASTA

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
