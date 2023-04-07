#!/bin/bash
#SBATCH --job-name=maker_Chromosome_002_round01
#SBATCH --partition condo
#SBATCH --qos condo
#SBATCH --constraint='256gb&douglas'
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

PROC=16

STORAGE="/storage/mussmann/dx_projects/dx2206"
SCRATCH="/scratch/$SLURM_JOB_ID"

PROGRAM="maker"
ROUND="01"

OPTS="maker_round01.ctl"

FASTA="Chromosome_002.fa"
TRANSFASTA="trinity_out_dir.Trinity.fasta"

GENOME="$STORAGE/current_draft/split/$FASTA"
TRANSCRIPTOME="$STORAGE/trinity/$TRANSFASTA"

CYPRINUS="GCF_018340385.1_ASM1834038v1_protein.faa"
DANIO="GCF_000002035.6_GRCz11_protein.faa"
PIMEPHALES="GCF_016745375.1_EPA_FHM_2.0_protein.faa"

REFSEQ="/storage/mussmann/refseq_proteome"
CYPDIR="$REFSEQ/GCF_018340385.1"
DANDIR="$REFSEQ/GCF_000002035.6"
PIMDIR="$REFSEQ/GCF_016745375.1"

REPMASK="pluc.full_mask.complex.reformat.gff3"

REPMASKDIR="$STORAGE/repeatmasker"

mkdir -p $SCRATCH/$PROGRAM/$ROUND

cd $SCRATCH/$PROGRAM/$ROUND
maker -CTL

rsync $SLURM_SUBMIT_DIR/$OPTS $SCRATCH/$PROGRAM/$ROUND/maker_opts.ctl
rsync $GENOME $SCRATCH/$PROGRAM/$ROUND/.
rsync $TRANSCRIPTOME $SCRATCH/$PROGRAM/$ROUND/.
rsync $CYPDIR/$CYPRINUS $SCRATCH/$PROGRAM/$ROUND/.
rsync $DANDIR/$DANIO $SCRATCH/$PROGRAM/$ROUND/.
rsync $PIMDIR/$PIMEPHALES $SCRATCH/$PROGRAM/$ROUND/.
rsync $REPMASKDIR/$REPMASK $SCRATCH/$PROGRAM/$ROUND/.

# run maker
sed -i 's/pluc_hic_genome.3ddna.fa/Chromosome_002.fa/g' maker_opts.ctl
maker -cpus $PROC -fix_nucleotides

rm $SCRATCH/$PROGRAM/$ROUND/$FASTA
rm $SCRATCH/$PROGRAM/$ROUND/$TRANSFASTA
rm $SCRATCH/$PROGRAM/$ROUND/$CYPRINUS
rm $SCRATCH/$PROGRAM/$ROUND/$DANIO
rm $SCRATCH/$PROGRAM/$ROUND/$PIMEPHALES
rm $SCRATCH/$PROGRAM/$ROUND/$REPMASK

mkdir -p $STORAGE/$PROGRAM
rsync -r $SCRATCH/$PROGRAM/ $STORAGE/$PROGRAM/.

exit
