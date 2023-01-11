#!/bin/bash

#module purge
#conda activate repeatmasker412

echo "If this script fail because of an error saying it \"cannot file a .pm file in @INC\" then see the comments in this processRM.sh script for the proper line of perl code that needs to be added to the rmOutToGFF3.pl file. It should have been installed as part of the RepeatMasker installation."
# if this script fails to run, you may need to add the following line to the rmOutToGFF3.pl file. You will need to correct the path in the line below so it points to your RepeatMasker installation on your system. The line should be added to the beginning after the file immediately after the #!/path/to/perl
#use lib qw( /home/mussmann/miniconda3/envs/repeatmasker412/share/RepeatMasker );

export REPEATMASKER_LIB_DIR="/home/mussmann/miniconda3/envs/repeatmasker412/share/RepeatMasker/Libraries"
export REPEATMASKER_MATRICES_DIR="/home/mussmann/miniconda3/envs/repeatmasker412/share/RepeatMasker/Matrices"

perl ~/miniconda3/envs/repeatmasker412/bin/rmOutToGFF3.pl pluc_hic_genome.salsa.p_rna.fa.out > pluc.full_mask.out.gff3
grep -v -e "Satellite" -e ")n" -e "-rich" pluc.full_mask.out.gff3 > pluc.full_mask.complex.gff3 

cat pluc.full_mask.complex.gff3 |   perl -ane '$id; if(!/^\#/){@F = split(/\t/, $_); chomp $F[-1];$id++; $F[-1] .= "\;ID=$id"; $_ = join("\t", @F)."\n"} print $_' > pluc.full_mask.complex.reformat.gff3

exit
