#!/bin/bash
#SBATCH --job-name=pluc_prinseq
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&256gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --exclusive
#SBATCH --time=240:00:00
#SBATCH --mail-type=ALL
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
source ~/miniconda3/etc/profile.d/conda.sh
conda activate prinseq0204

PROC=16

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"
PROGRAM="prinseq"

RAW="$STORAGE/silva_align"

mkdir -p $SCRATCH/$PROGRAM

rsync $RAW/*.fastq.gz $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

for file in $SCRATCH/$PROGRAM/*_R1_001.fastq.gz
do
	read1=$file
	read2=${file%_R1_001.fastq.gz}_R2_001.fastq.gz

	bn1="$(basename -- $read1)"
	bn2="$(basename -- $read2)"

	gunzip $read1
	gunzip $read2

	prinseq-lite.pl -fastq ${read1%.gz} -fastq2 ${read2%.gz} -out_format 3 -trim_tail_left 5 -trim_tail_right 5 -min_len 35

	rm *_bad_*.fastq
	rm *_good_singletons_*.fastq

	for fq in *_prinseq_good_*.fastq
	do
		f=`echo $fq | awk -F"_prinseq_" '{print $1}'`
		mv $fq $f.fastq

		gzip $f.fastq
	done
done

rm $SCRATCH/$PROGRAM/$FASTA

mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
