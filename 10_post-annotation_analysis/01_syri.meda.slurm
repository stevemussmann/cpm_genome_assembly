#!/bin/bash
#SBATCH --job-name=pluc_syri_meda
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
conda activate minimap2

PROC=16

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="syri/meda"
CHRLIST="mefuList.txt"

## make working directory
mkdir -p $SCRATCH/$PROGRAM

## genomes
# meda
MEFUDIR="/storage/mussmann/genomes/Meda_fulgida/GCA_030578275.1_ASM3057827v1"
MEFU="GCA_030578275.1_ASM3057827v1_genomic.fna"

# ptychocheilus
PLUCDIR="${STORAGE}/current_draft"
PLUC="pluc_hic_genome.3ddna.clean.nocontamination.renamed.masked.fa"

## copy genomes
rsync "${MEFUDIR}/${MEFU}.gz" $SCRATCH/$PROGRAM/.
rsync "${PLUCDIR}/${PLUC}" $SCRATCH/$PROGRAM/.
cp $SLURM_SUBMIT_DIR/revcomList.pl $SCRATCH/$PROGRAM/.
cp $SLURM_SUBMIT_DIR/$CHRLIST $SCRATCH/$PROGRAM/.

## change directories and unzip genomes
cd $SCRATCH/$PROGRAM
gunzip *.gz

## filter genome files to get only chromosomes
# meda
MEFULN=`grep -wn ">JAROOJ010000026.1" $MEFU | cut -d: -f1`
MEFULN=$(($MEFULN-1))
head -${MEFULN} $MEFU > ${MEFU}.filtered

# ptychocheilus
# convert from multiline fastadd
perl -pe '$. > 1 and /^>/ ? print "\n" : chomp' $PLUC > tmp.fa
mv tmp.fa $PLUC
# reverse complement the necessary sequences
./revcomList.pl -f $PLUC -c $CHRLIST -o plucout.txt
mv plucout.txt $PLUC
PLUCLN=`grep -wn ">Unplaced_scaffold_1" $PLUC | cut -d: -f1`
PLUCLN=$(($PLUCLN-1))
head -${PLUCLN} $PLUC > ${PLUC}.filtered

## map ptychocheilus to genomes
minimap2 -ax asm10 -t $PROC --eqx ${MEFU}.filtered ${PLUC}.filtered > mefu.sam

## convert sam to bam
samtools view -b mefu.sam > mefu.bam
samtools index mefu.bam

## run syri
conda deactivate
conda activate syri163
syri -c mefu.bam -r ${MEFU}.filtered -q ${PLUC}.filtered -k -F B

## run plotsr
conda deactivate
conda activate plotsr111

# make genomes file
GENS="genomes.txt"
SPECIES1="Meda"
SPECIES2="Ptychocheilus"
echo -e "#file\tname\ttags" > $GENS
echo -e "${MEFU}.filtered\t${SPECIES1}\tlw:1.5" >> $GENS
echo -e "${PLUC}.filtered\t${SPECIES2}\tlw:1.5" >> $GENS

#plotsr syri.out ${MEFU}.filtered ${PLUC}.filtered -H 8 -W 5
plotsr --sr syri.out --genomes $GENS -o ${SPECIES1}_x_${SPECIES2}_plot.png -d 600

## cleanup
rm *.sam
rm $MEFU
rm $PLUC

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit

