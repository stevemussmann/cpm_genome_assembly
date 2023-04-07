#!/bin/bash
#SBATCH --job-name=pluc_snap_round01
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
conda activate maker30103
export LIBDIR="/home/mussmann/miniconda3/envs/maker30103/share/RepeatMasker/Libraries"

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"

PROGRAM="snap"
ROUND="01"
BASE="pluc_round01"
DATASTORE="${BASE}.maker.output/${BASE}_datastore"

MAKER="${STORAGE}/maker/${ROUND}"
mkdir -p $SCRATCH/$PROGRAM/$ROUND/$DATASTORE

# copy individual maker files
rsync -r $MAKER/*.maker.output/*_datastore/* $SCRATCH/$PROGRAM/$ROUND/$DATASTORE/.
rsync $MAKER/maker_*.ctl $SCRATCH/$PROGRAM/$ROUND/.

# copy other files needed for maker
TRANSFASTA="trinity_out_dir.Trinity.fasta"
TRANSCRIPTOME="$STORAGE/trinity/$TRANSFASTA"

FASTA="pluc_hic_genome.3ddna.fa"
GENOME="$STORAGE/current_draft/split/$FASTA"

CYPRINUS="GCF_018340385.1_ASM1834038v1_protein.faa"
DANIO="GCF_000002035.6_GRCz11_protein.faa"
PIMEPHALES="GCF_016745375.1_EPA_FHM_2.0_protein.faa"

REFSEQ="/storage/mussmann/refseq_proteome"
CYPDIR="$REFSEQ/GCF_018340385.1"
DANDIR="$REFSEQ/GCF_000002035.6"
PIMDIR="$REFSEQ/GCF_016745375.1"

REPMASK="pluc.full_mask.complex.reformat.gff3"
REPMASKDIR="$STORAGE/repeatmasker"

rsync $GENOME $SCRATCH/$PROGRAM/$ROUND/.
rsync $TRANSCRIPTOME $SCRATCH/$PROGRAM/$ROUND/.
rsync $CYPDIR/$CYPRINUS $SCRATCH/$PROGRAM/$ROUND/.
rsync $DANDIR/$DANIO $SCRATCH/$PROGRAM/$ROUND/.
rsync $PIMDIR/$PIMEPHALES $SCRATCH/$PROGRAM/$ROUND/.
rsync $REPMASKDIR/$REPMASK $SCRATCH/$PROGRAM/$ROUND/.

cd $SCRATCH/$PROGRAM/$ROUND

# combine the outputs from all the maker runs
maker -dsindex -base $BASE -g $FASTA

# get full GFF
gff3_merge -s -d ${BASE}.maker.output/${BASE}_master_datastore_index.log > ${BASE}.all.maker.gff

# get full GFF without sequences
gff3_merge -n -s -d ${BASE}.maker.output/${BASE}_master_datastore_index.log > ${BASE}.all.maker.noseq.gff

# get amino acid fastas of genes and transcripts
fasta_merge -d ${BASE}.maker.output/${BASE}_master_datastore_index.log

# Selecting 'confident' gene models from maker
maker2zff -x 0.25 -l 50 -d ${BASE}.maker.output/${BASE}_master_datastore_index.log
newname="${BASE}.zff.length50_aed0.25"
mv genome.ann ${newname}.ann
mv genome.dna ${newname}.dna

# run snap
# gather stats and validate
fathom ${newname}.ann ${newname}.dna -gene-stats > gene-stats.log 2>&1
fathom ${newname}.ann ${newname}.dna -validate > validate.log 2>&1

# collect traning sequences and annotations plus 1000 surrounding bp for training
fathom ${newname}.ann ${newname}.dna -categorize 1000 > categorize.log 2>&1
fathom uni.ann uni.dna -export 1000 -plus > uni-plus.log 2>&1

mkdir params
cd params
forge ../export.ann ../export.dna > ../forge.log 2>&1

cd ..

hmm-assembler.pl $newname params > ${newname}.hmm

mkdir $STORAGE/$PROGRAM/
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
