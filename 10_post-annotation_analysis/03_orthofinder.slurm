#!/bin/bash
#SBATCH --job-name=pluc_orthofinder
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
conda activate orthofinder255

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"
PROGRAM="orthofinder"

# list file names and parameters
GENOMEDIR="/storage/mussmann/genomes"
# common carp Cyprinus carpio GCF_018340385.1
CYCA="GCF_018340385.1_ASM1834038v1_protein.faa"
CYCADIR="$GENOMEDIR/Cyprinus_carpio/GCF_018340385.1_ASM1834038v1/${CYCA}.gz"
# goldfish Carassius auratus GCF_003368295.1
CAAU="GCF_003368295.1_ASM336829v1_protein.faa"
CAAUDIR="$GENOMEDIR/Carassius_auratus/GCF_003368295.1_ASM336829v1/${CAAU}.gz"
# zebrafish Danio rerio GCF_000002035.6
DARE="GCF_000002035.6_GRCz11_protein.faa"
DAREDIR="$GENOMEDIR/Danio_rerio/current/${DARE}.gz"
# fathead minnow Pimephales promelas GCF_016745375.1
PIPR="GCF_016745375.1_EPA_FHM_2.0_protein.faa"
PIPRDIR="$GENOMEDIR/Pimephales_promelas/GCF_016745375.1_EPA_FHM_2.0/${PIPR}.gz"
# speckled dace Rhinichthys klamathensis GCF_029890125.1
RHKL="GCF_029890125.1_OSU_Roscu_1.1_protein.faa"
RHKLDIR="$GENOMEDIR/Rhinichthys_klamathensis/GCF_029890125.1_OSU_Roscu_1.1/${RHKL}.gz"

# pikeminnow proteins
PTLU="Ptychocheilus_lucius.proteins.fa"
PTLUDIR="$STORAGE/funannotate/output/annotate_results/$PTLU"

PROC=32

# make scratch directory
mkdir -p $SCRATCH/$PROGRAM

# copy files
rsync $CYCADIR $SCRATCH/$PROGRAM/.
rsync $CAAUDIR $SCRATCH/$PROGRAM/.
rsync $DAREDIR $SCRATCH/$PROGRAM/.
rsync $PIPRDIR $SCRATCH/$PROGRAM/.
rsync $RHKLDIR $SCRATCH/$PROGRAM/.
rsync $SLURM_SUBMIT_DIR/getLongestTranscript.pl $SCRATCH/$PROGRAM/.
rsync $PTLUDIR $SCRATCH/$PROGRAM/.

# change directories
cd $SCRATCH/$PROGRAM

# unzip files
gunzip *.gz

## get longest transcripts
#genbank
for file in *.faa
do
	primary_transcript.py $file
done
# pikeminnow
chmod u+x getLongestTranscript.pl
./getLongestTranscript.pl -f $PTLU
mv ${PTLU%.fa}.longest.fa $SCRATCH/$PROGRAM/primary_transcripts/${PTLU%.fa}.faa

# run orthofinder
orthofinder -f $SCRATCH/$PROGRAM/primary_transcripts/

# copy results to storage
mkdir $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
