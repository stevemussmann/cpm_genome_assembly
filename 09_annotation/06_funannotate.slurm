#!/bin/bash
#SBATCH --job-name=pluc_funannotate
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='douglas&768gb'
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
#SBATCH --exclusive
#SBATCH --time=24:00:00
#SBATCH -e %j.err
#SBATCH -o %j.out

module purge
source ~/miniconda3/etc/profile.d/conda.sh
conda activate funannotate

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="funannotate"

# list file names and parameters
FASTA="pluc_hic_genome.3ddna.clean.nocontamination.renamed.masked.fa"
GFF="braker.gff3"
EGGNOG="out.emapper.annotations"
IPS="pluc_ips.xml"
DB="actinopterygii"
OUT="output"
PROC=32

# make scratch directory
mkdir -p $SCRATCH/$PROGRAM/output

# copy files
rsync $STORAGE/braker/braker/$GFF $SCRATCH/$PROGRAM/.
rsync $STORAGE/current_draft/$FASTA $SCRATCH/$PROGRAM/.
rsync $STORAGE/eggnog/eggnog-mapper.embl.de/MM_e8wwlzwx/$EGGNOG $SCRATCH/$PROGRAM/.
rsync $STORAGE/interproscan/$IPS $SCRATCH/$PROGRAM/.

# change directories
cd $SCRATCH/$PROGRAM

# scaffold names are too long and had to be shortened
sed -i 's/Unplaced_scaffold/UnplScaf/g' $GFF
sed -i 's/Unplaced_scaffold/UnplScaf/g' $FASTA
sed -i 's/Unplaced_scaffold/UnplScaf/g' $EGGNOG
sed -i 's/Unplaced_scaffold/UnplScaf/g' $IPS

# run funannotate
funannotate annotate --gff $GFF --fasta $FASTA --eggnog $EGGNOG --iprscan $IPS --busco_db $DB --out $OUT --species "Ptychocheilus lucius" --cpus $PROC --force

# copy results to storage
mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
