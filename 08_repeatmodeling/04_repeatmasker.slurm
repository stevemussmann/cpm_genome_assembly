#!/bin/bash
#SBATCH --job-name=pluc_repeatmasker
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
conda activate repeatmasker412

export REPEATMASKER_LIB_DIR="/home/mussmann/miniconda3/envs/repeatmasker412/share/RepeatMasker/Libraries"
export REPEATMASKER_MATRICES_DIR="/home/mussmann/miniconda3/envs/repeatmasker412/share/RepeatMasker/Matrices"

PROC=32
PA=$(($PROC/4))

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="repeatmasker"

FASTA="pluc_hic_genome.3ddna.fa"
RB="vrtrep.ref"
RM="pluc-families.filtered.fa"

GENOME="$STORAGE/current_draft/$FASTA"
REPBASE="/storage/mussmann/repbase/RepBase27.08.fasta/$RB"
REPMOD="$STORAGE/blast_rm_swissprot/$RM"

#mkdir -p $SCRATCH/$PROGRAM/libdir
mkdir -p $SCRATCH/$PROGRAM

rsync $GENOME $SCRATCH/$PROGRAM/.
rsync $REPBASE $SCRATCH/$PROGRAM/.
rsync $REPMOD $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

#cat $RB $RM > $SCRATCH/$PROGRAM/libdir/pluc-custom-lib.fa
cat $RB $RM > $SCRATCH/$PROGRAM/pluc-custom-lib.fa

#RepeatMasker -s -pa $PA -lib pluc-custom-lib.fa -xsmall -gff -libdir $SCRATCH/$PROGRAM/libdir -dir . $FASTA
RepeatMasker -s -pa $PA -lib pluc-custom-lib.fa -xsmall -gff -dir . $FASTA

rm $SCRATCH/$PROGRAM/$FASTA
rm $SCRATCH/$PROGRAM/$RB
rm $SCRATCH/$PROGRAM/$RM

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
