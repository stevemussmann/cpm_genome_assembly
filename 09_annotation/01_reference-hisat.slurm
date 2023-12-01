#!/bin/bash
#SBATCH --job-name=pluc_hisat
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
conda activate hisat221

PROC=16

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="hisat"

FASTA="pluc_hic_genome.3ddna.clean.nocontamination.renamed.fa"
DB="pluc"

GENOME="$STORAGE/current_draft/$FASTA"
RAW="$STORAGE/prinseq"

mkdir -p $SCRATCH/$PROGRAM

rsync $RAW/*.fastq.gz $SCRATCH/$PROGRAM/.
rsync $GENOME $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

#index the genome
hisat2-build -p $PROC $FASTA $DB

#align reads
for file in *_R1_001.fastq.gz
do
	read1=$file
	read2="${file%_R1_001.fastq.gz}_R2_001.fastq.gz"

	sam="$(basename -- $read1)"
	sam=${sam%_L002_R1_001.fastq.gz}.sam

	hisat2 -p $PROC --dta --very-sensitive -x $DB -1 $read1 -2 $read2 --rna-strandness RF -S $sam

	conda deactivate
	conda activate samtools1151

	rm $read1
	rm $read2
	
	samtools view -bS $sam > ${sam%.sam}_unsorted.bam
	rm $sam

	samtools sort -@ $PROC -o ${sam%.sam}.bam ${sam%.sam}_unsorted.bam
	rm ${sam%.sam}_unsorted.bam

	conda deactivate
	conda activate hisat221
done

rm $SCRATCH/$PROGRAM/$FASTA

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit

