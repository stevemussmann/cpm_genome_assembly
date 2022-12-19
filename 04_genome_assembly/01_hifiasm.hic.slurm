#!/bin/bash
#SBATCH --job-name=pluc_hifiasm
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
module load os/el7 intel/14.0.3 openmpi/1.8.8 python/2.7.11 mkl/14.0.3 java/sunjdk_1.8.0_72 boost/1.60.0 gsl/2.4-gcc

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"

OUT="pluc_hic_genome.asm"
OUTDIR="hifiasm_hic"
PROC=32

FILE1="m64047_220829_191921.ccs.filt.fastq.gz"
FILE2="m64047_220831_061814.ccs.filt.fastq.gz"

HIC1="Fish_HiC_S1_L001_R1_001_val_1.fq.gz"
HIC2="Fish_HiC_S1_L001_R2_001_val_2.fq.gz"

mkdir -p $SCRATCH/$OUTDIR

rsync $STORAGE/hifiadapterfilt/$FILE1 $SCRATCH/$OUTDIR/.
rsync $STORAGE/hifiadapterfilt/$FILE2 $SCRATCH/$OUTDIR/.
rsync $STORAGE/trimgalore_hic/trimmed/*val_*.fq.gz $SCRATCH/$OUTDIR/.

cd $SCRATCH/$OUTDIR

hifiasm -o $OUT -t $PROC --h1 $HIC1 --h2 $HIC2 $FILE1 $FILE2
rm $SCRATCH/$OUTDIR/$FILE1
rm $SCRATCH/$OUTDIR/$FILE2
rm $SCRATCH/$OUTDIR/$HIC1
rm $SCRATCH/$OUTDIR/$HIC2

awk '/^S/{print ">"$2;print $3}' ${OUT}.hic.p_ctg.gfa > pluc_hic_genome.fa

mkdir -p $STORAGE/$OUTDIR
rsync -r $SCRATCH/$OUTDIR/ $STORAGE/$OUTDIR/.

exit
