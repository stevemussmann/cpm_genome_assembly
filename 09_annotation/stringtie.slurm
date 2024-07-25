#!/bin/bash
#SBATCH --job-name=pluc_stringtie
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&768gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --exclusive
#SBATCH --time=240:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=smussmann@gmail.com
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
source ~/miniconda3/etc/profile.d/conda.sh
conda activate stringtie221

PROC=32

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="stringtie"

BAM="$STORAGE/hisat"

MERGELIST="pluc_mergelist.txt"
MERGEDGTF="pluc_stringtie_transcriptome.gtf"

mkdir -p $SCRATCH/$PROGRAM

rsync $BAM/*.bam $SCRATCH/$PROGRAM/.

cd $SCRATCH/$PROGRAM

#align reads
for file in *.bam
do
	bn="$(basename -- $file)"
	outname=${bn%.bam}.gtf

	#make sample label
	label=`echo $outname | awk -F"_" '{print $1"_"$2"_"$4}'`

	stringtie -p $PROC -o $outname --rf -l $label $file

	echo $outname >> $MERGELIST

	rm $file
done

stringtie --merge -p $PROC -o $MERGEDGTF $MERGELIST

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit

