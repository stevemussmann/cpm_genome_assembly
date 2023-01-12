#!/bin/bash
#SBATCH --job-name=pluc_minimap2
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
conda activate minimap2

PROC=16

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
RAW="$STORAGE/raw/pacbio"
PROGRAM="minimap2/contigs"

FASTA="pluc_hic_genome.fa"
GENOME="$STORAGE/current_draft/$FASTA"

HIFI1="m64047_220829_191921.ccs.filt.fastq.gz"
HIFI2="m64047_220831_061814.ccs.filt.fastq.gz"

mkdir -p $SCRATCH/$PROGRAM

rsync $STORAGE/hifiadapterfilt/$HIFI1 $SCRATCH/$PROGRAM/.
rsync $STORAGE/hifiadapterfilt/$HIFI2 $SCRATCH/$PROGRAM/.
rsync $GENOME $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

#map reads to genome
minimap2 -ax map-hifi -t $PROC $FASTA $HIFI1 $HIFI2 | samtools sort -@ $PROC -O BAM -o ${FASTA%.fa}.bam -

rm $SCRATCH/$PROGRAM/$FASTA
rm $SCRATCH/$PROGRAM/$HIFI1
rm $SCRATCH/$PROGRAM/$HIFI2

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit

