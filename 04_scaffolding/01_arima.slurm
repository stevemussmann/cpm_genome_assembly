#!/bin/bash
#SBATCH --job-name=pluc_arima
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
module load os/el7 intel/14.0.3 openmpi/1.8.8 python/2.7.11 mkl/14.0.3 java/sunjdk_1.8.0_72 boost/1.60.0 gsl/2.4-gcc

STORAGE="/storage/mussmann/dx_projects/dx2206"
SUBDIR="$SLURM_SUBMIT_DIR"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="arima"

FASTA="pluc_hic_genome.fa"
HIC1="Fish_HiC_S1_L001_R1_001_val_1.fq.gz"
HIC2="Fish_HiC_S1_L001_R2_001_val_2.fq.gz"
RENAME1="Fish_HiC_1.fastq.gz"
RENAME2="Fish_HiC_2.fastq.gz"

GENOME="$STORAGE/current_draft/$FASTA"
HIC1DIR="$STORAGE/trimgalore_hic/trimmed/$HIC1"
HIC2DIR="$STORAGE/trimgalore_hic/trimmed/$HIC2"

mkdir -p $SCRATCH/$PROGRAM

rsync $GENOME $SCRATCH/$PROGRAM/.
rsync $HIC1DIR $SCRATCH/$PROGRAM/$RENAME1
rsync $HIC2DIR $SCRATCH/$PROGRAM/$RENAME2

cd $SCRATCH/$PROGRAM

## much of the following code was borrowed from the Arima mapping pipeline
## available at https://github.com/ArimaGenomics/mapping_pipeline

# run mapping_pipeline
##########################################
# Commands #
##########################################

SRA='Fish_HiC'
LABEL='Pluc_HiC'
BWA='/home/mussmann/local/src/bwa/bwa-0.7.12/bwa'
SAMTOOLS='/home/mussmann/local/src/samtools/samtools-1.3.1/samtools'
IN_DIR=$SCRATCH/$PROGRAM
REF=$SCRATCH/$PROGRAM/$FASTA
FAIDX="$REF.fai"
PREFIX="$REF"
RAW_DIR=$SCRATCH/$PROGRAM/bam/raw/out
FILT_DIR=$SCRATCH/$PROGRAM/bam/filt/out
FILTER='/home/mussmann/local/src/mapping_pipeline/filter_five_end.pl'
COMBINER='/home/mussmann/local/src/mapping_pipeline/two_read_bam_combiner.pl'
STATS='/home/mussmann/local/src/mapping_pipeline/get_stats.pl'
PICARD='/home/mussmann/local/src/picard/picard.jar'
TMP_DIR=$SCRATCH/$PROGRAM/tmp
PAIR_DIR=$SCRATCH/$PROGRAM/pair
REP_DIR=$SCRATCH/$PROGRAM/rep
REP_LABEL=${LABEL}_rep1
MERGE_DIR=$SCRATCH/$PROGRAM/merge
MAPQ_FILTER=10
CPU=16

echo "### Step 0: Check output directories exist & create them as needed"
[ -d $RAW_DIR ] || mkdir -p $RAW_DIR
[ -d $FILT_DIR ] || mkdir -p $FILT_DIR
[ -d $TMP_DIR ] || mkdir -p $TMP_DIR
[ -d $PAIR_DIR ] || mkdir -p $PAIR_DIR
[ -d $REP_DIR ] || mkdir -p $REP_DIR
[ -d $MERGE_DIR ] || mkdir -p $MERGE_DIR

echo "### Step 0: Index reference" # Run only once! Skip this step if you have already generated BWA index files
$BWA index -a bwtsw -p $PREFIX $REF

echo "### Step 1.A: FASTQ to BAM (1st)"
$BWA mem -t $CPU $REF $IN_DIR/${SRA}_1.fastq.gz | $SAMTOOLS view -@ $CPU -Sb - > $RAW_DIR/${SRA}_1.bam
rm ${SRA}_1.fastq.gz

echo "### Step 1.B: FASTQ to BAM (2nd)"
$BWA mem -t $CPU $REF $IN_DIR/${SRA}_2.fastq.gz | $SAMTOOLS view -@ $CPU -Sb - > $RAW_DIR/${SRA}_2.bam
rm ${SRA}_2.fastq.gz

echo "### Step 2.A: Filter 5' end (1st)"
$SAMTOOLS view -h $RAW_DIR/${SRA}_1.bam | perl $FILTER | $SAMTOOLS view -Sb - > $FILT_DIR/${SRA}_1.bam

echo "### Step 2.B: Filter 5' end (2nd)"
$SAMTOOLS view -h $RAW_DIR/${SRA}_2.bam | perl $FILTER | $SAMTOOLS view -Sb - > $FILT_DIR/${SRA}_2.bam

echo "### Step 3A: Pair reads & mapping quality filter"
perl $COMBINER $FILT_DIR/${SRA}_1.bam $FILT_DIR/${SRA}_2.bam $SAMTOOLS $MAPQ_FILTER | $SAMTOOLS view -bS -t $FAIDX - | $SAMTOOLS sort -@ $CPU -o $TMP_DIR/$SRA.bam -

echo "### Step 3.B: Add read group"
java -Xmx4G -Djava.io.tmpdir=temp/ -jar $PICARD AddOrReplaceReadGroups INPUT=$TMP_DIR/$SRA.bam OUTPUT=$PAIR_DIR/$SRA.bam ID=$SRA LB=$SRA SM=$LABEL PL=ILLUMINA PU=none

echo "### Step 4: Mark duplicates"
java -Xmx30G -XX:-UseGCOverheadLimit -Djava.io.tmpdir=temp/ -jar $PICARD MarkDuplicates INPUT=$PAIR_DIR/$SRA.bam OUTPUT=$REP_DIR/$REP_LABEL.bam METRICS_FILE=$REP_DIR/metrics.$REP_LABEL.txt TMP_DIR=$TMP_DIR ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT REMOVE_DUPLICATES=TRUE

$SAMTOOLS index $REP_DIR/$REP_LABEL.bam

perl $STATS $REP_DIR/$REP_LABEL.bam > $REP_DIR/$REP_LABEL.bam.stats

echo "Finished Mapping Pipeline through Duplicate Removal"


rm $SCRATCH/$PROGRAM/$GENOME
rm $SCRATCH/$PROGRAM/

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
