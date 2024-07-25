#!/bin/bash
#SBATCH --job-name=pluc_gffread
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
conda activate gffread0127

PROC=32

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="gffread"
SCRIPT="getLongestTranscript.pl"

FASTA="pluc_hic_genome.3ddna.clean.nocontamination.renamed.fa"

GENOME="$STORAGE/current_draft/$FASTA"

mkdir -p $SCRATCH/$PROGRAM

rsync $GENOME $SCRATCH/$PROGRAM/.

rsync $STORAGE/stringtie/*.gtf $SCRATCH/$PROGRAM/.
rsync $SLURM_SUBMIT_DIR/$SCRIPT $SCRATCH/$PROGRAM/.
chmod u+x $SCRIPT

cd $SCRATCH/$PROGRAM

for file in *.gtf
do
	gffread -w "${file%.gtf}.fasta" -g $FASTA $file
	gffread -E $file -o- > ${file%.gtf}.gff
	./getLongestTranscript.pl -f ${file%.gtf}.fasta
done

rm $SCRATCH/$PROGRAM/$FASTA
rm $SCRATCH/$PROGRAM/*.gtf

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
