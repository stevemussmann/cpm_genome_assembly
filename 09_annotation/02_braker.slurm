#!/bin/bash
#SBATCH --job-name=pluc_braker
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
module load singularity/3.9.7

PROC=32

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/local_scratch/$SLURM_JOB_ID"

PROGRAM="braker"
SPECIES="Plucius"

FASTA="pluc_hic_genome.3ddna.clean.nocontamination.renamed.masked.fa"
GENOME="$STORAGE/current_draft/$FASTA"
BAMDIR="$STORAGE/hisat"
SPFASTA="uniprot_sprot.fasta"
SWISSPROT="/storage/mussmann/sprot_blastdb/2023-11-30/$SPFASTA"

# proteome list
GDIR="/storage/mussmann/genomes"
AMEX="${GDIR}/Astyanax_mexicanus/GCF_023375975.1_AstMex3_surface/GCF_023375975.1_AstMex3_surface_protein.faa.gz"
CAUR="${GDIR}/Carassius_auratus/GCF_003368295.1_ASM336829v1/GCF_003368295.1_ASM336829v1_protein.faa.gz"
CCAR="${GDIR}/Cyprinus_carpio/GCF_018340385.1_ASM1834038v1/GCF_018340385.1_ASM1834038v1_protein.faa.gz"
DRER="${GDIR}/Danio_rerio/current/GCF_000002035.6_GRCz11_protein.faa.gz"
IPUN="${GDIR}/Ictalurus_punctatus/GCF_001660625.3_Coco_2.0/GCF_001660625.3_Coco_2.0_protein.faa.gz"
MASI="${GDIR}/Myxocyprinus_asiaticus/GCF_019703515.2_UBuf_Myxa_2/GCF_019703515.2_UBuf_Myxa_2_protein.faa.gz"
PPRO="${GDIR}/Pimephales_promelas/GCF_016745375.1_EPA_FHM_2.0/GCF_016745375.1_EPA_FHM_2.0_protein.faa.gz"
XTEX="${GDIR}/Xyrauchen_texanus/GCF_025860055.1_RBS_HiC_50CHRs/GCF_025860055.1_RBS_HiC_50CHRs_protein.faa.gz"

mkdir -p $SCRATCH/$PROGRAM

cd $SCRATCH/$PROGRAM

rsync $GENOME $SCRATCH/$PROGRAM/.
rsync $BAMDIR/*.bam $SCRATCH/$PROGRAM/.
rsync $SWISSPROT $SCRATCH/$PROGRAM/${SPFASTA%.fasta}.faa

# copy proteomes
rsync $AMEX $SCRATCH/$PROGRAM/.
rsync $CAUR $SCRATCH/$PROGRAM/.
rsync $CCAR $SCRATCH/$PROGRAM/.
rsync $DRER $SCRATCH/$PROGRAM/.
rsync $IPUN $SCRATCH/$PROGRAM/.
rsync $MASI $SCRATCH/$PROGRAM/.
rsync $PPRO $SCRATCH/$PROGRAM/.
rsync $XTEX $SCRATCH/$PROGRAM/.
gunzip *.gz

# make list of proteomes
PARRAY=($(ls -d *.faa))
PLINE=`for i in "${PARRAY[@]}"; do echo -ne "$SCRATCH/$PROGRAM/$i,"; done;`
PROLIST=`echo $PLINE | sed 's/,$//g'`

# make list of bam files
ARRAY=($(ls -d *.bam))
LINE=`for i in "${ARRAY[@]}"; do echo -ne "$SCRATCH/$PROGRAM/$i,"; done;`
BAMLIST=`echo $LINE | sed 's/,$//g'`

# run maker
singularity exec --bind /local_scratch:/local_scratch $HOME/braker3.sif braker.pl \
	--species=$SPECIES --genome=${SCRATCH}/${PROGRAM}/${FASTA} \
	--bam=$BAMLIST --gff3 --threads $PROC --useexisting --prot_seq=$PROLIST

rm $SCRATCH/$PROGRAM/$FASTA
rm $SCRATCH/$PROGRAM/*.bam
rm $SCRATCH/$PROGRAM/${SPFASTA%.fasta}.faa

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
