#!/bin/bash

CLASSIFIED="pluc_classified.fa"
UNCLASSIFIED="pluc_unclassified.fa"

REMOVE="pluc_hic_genome.3ddna.kraken2.removed.fa"
NOCONTAM="pluc_hic_genome.3ddna.nocontamination.fa"

#9606 is human - ignoring those pulls out just fungus and bacteria matches
grep -v 9606 $CLASSIFIED | grep -A 1 ">" > $REMOVE

# remove the lines with dashes that were added by the above code for some reason
grep -v -- "-" $REMOVE > tmp
mv tmp $REMOVE

# cat the unclassified scaffolds back to the classified fasta
cat $UNCLASSIFIED >> $CLASSIFIED

./matchHeader.pl -c $CLASSIFIED -r $REMOVE -o $NOCONTAM


exit 
