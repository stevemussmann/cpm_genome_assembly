#!/bin/bash

#9606 is human - ignoring those pulls out just fungus and bacteria matches
grep -v 9606 pluc_classified.txt | grep -A 1 ">" > pluc_hic_genome.3ddna.kraken2.removed.fa



exit 
