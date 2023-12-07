# 09: Annotation 

This directory contains RNA alignment, genome annotation, and functional annotation scripts.

As an additional step to the scripts listed above - the `braker.aa` file output from braker3 had stop codons stripped from it using the command `sed -i 's/\*//g' braker.aa`. It was then submitted to the eggNOG-mapper server `http://eggnog-mapper.embl.de/` and analyzed using default settings. The output of this pipeline was then used as input for the `05_funannotate.slurm` script.
