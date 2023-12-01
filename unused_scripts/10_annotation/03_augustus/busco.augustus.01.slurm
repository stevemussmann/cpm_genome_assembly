#!/bin/bash
#SBATCH --job-name=pluc_busco-augustus
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&256gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
#SBATCH --exclusive
#SBATCH --time=2400:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
source ~/miniconda3/etc/profile.d/conda.sh

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="augustus"
ROUND="01"

# make directories and copy appropriate files
mkdir -p $SCRATCH/$PROGRAM/$ROUND
cd $SCRATCH/$PROGRAM/$ROUND

SNAP=$STORAGE/snap/$ROUND
FILE="pluc_round${ROUND}.all.maker.noseq.gff"

FASTA="pluc_round${ROUND}.all.maker.transcripts1000.fasta"

GFASTA="pluc_hic_genome.3ddna.fa"
GENOME="$STORAGE/current_draft/$GFASTA"

rsync $SNAP/$FILE $SCRATCH/$PROGRAM/$ROUND/.
rsync $GENOME $SCRATCH/$PROGRAM/$ROUND/.

# extract mRNAs with 1000bp flanking sequence using bedtools
conda activate bedtools2300
awk -v OFS="\t" '{ if ($3 == "mRNA") print $1, $4, $5 }' $FILE | awk -v OFS="\t" '{ if ($2 < 1000) print $1, "0", $3+1000; else print $1, $2-1000, $3+1000 }' | bedtools getfasta -fi $GFASTA -bed - -fo $FASTA
conda deactivate

# remove duplicated sequences by fasta ID
conda activate seqkit
seqkit rmdup < $FASTA > tmp.fa
mv tmp.fa $FASTA
conda deactivate

# settings for busco
OUT="pluc_busco-augustus${ROUND}"
PROC=16

# run busco
conda activate busco543
busco -c $PROC -m genome -i $FASTA -o $OUT -l actinopterygii_odb10 --augustus_species zebrafish --augustus_parameters='--progress=true' --long

# cleanup
rm $SCRATCH/$PROGRAM/$ROUND/$GFASTA
rm $SCRATCH/$PROGRAM/$ROUND/$FILE

mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
