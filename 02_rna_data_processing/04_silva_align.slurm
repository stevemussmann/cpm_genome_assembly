#!/bin/bash
#SBATCH --job-name=pluc_silva_align
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
PROGRAM="silva_align"
DB="ribosomal"

RAW="$STORAGE/trimgalore/trimmed"
SILVA="/storage/mussmann/silva/SILVA_138.1_LSUParc+SSUParc_tax_silva.dna.fasta"

PROC=32

mkdir -p $SCRATCH/$PROGRAM/db

rsync $SILVA $SCRATCH/$PROGRAM/db/.

rsync $RAW/*kept_val_*.fq.gz $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

bowtie2-build --quiet --threads $PROC $SCRATCH/$PROGRAM/db/SILVA_138.1_LSUParc+SSUParc_tax_silva.dna.fasta $DB

# run Trinity
for file1 in *R1_001.cor.kept_val_1.fq.gz
do
	file2="${file1%R1_001.cor.kept_val_1.fq.gz}R2_001.cor.kept_val_2.fq.gz"
	sampleid=${file1%R1_001.cor.kept_val_1.fq.gz}
	bowtie2 --quiet -p $PROC --very-sensitive-local --phred33 --nofw -x $DB -1 $file1 -2 $file2 \
		--threads 12 --met-file ${sampleid}_bowtie2_metrics.txt \
		--al-conc-gz blacklist_paired_aligned_${sampleid}.fq.gz \
		--un-conc-gz blacklist_paired_unaligned_${sampleid}.fq.gz \
		--al-gz blacklist_unpaired_aligned_${sampleid}.fq.gz \
		--un-gz blacklist_unpaired_unaligned_${sampleid}.fq.gz
done

rm Pluc_transcriptome_*_R*_*.cor.kept_val_*.fq.gz
rm *.bt2l
rm -r $SCRATCH/$PROGRAM/db/

mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
