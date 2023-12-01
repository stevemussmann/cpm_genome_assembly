#!/bin/bash

module purge
source ~/miniconda3/etc/profile.d/conda.sh
conda activate seqkit

INFASTA="pluc_hic_genome.3ddna.fa"
OUTDIR="splitdir"
mkdir $OUTDIR

seqkit split -i $INFASTA -O $OUTDIR/ --force

cd $OUTDIR
for file in *.fa
do
        fn=`echo $file | sed 's/pluc_hic_genome.3ddna.part_//g'`
        mv $file $fn
done

cat Unplaced_scaffold_* > Unplaced_scaffolds.fa
rm Unplaced_scaffold_*

exit
