# 10: Post-annotation Analysis

`revcomList.pl` is used to selectively reverse complement chromosomes in the Colorado Pikeminnow genome to allow comparison with Spikedace and Loach Minnow in SyRI

`mefuList.txt` and `ticoList.txt` contain the lists of Colorado Pikeminnow chromosomes that need to be reverse complemented for comparison to Spikedace and Loach Minnow, respectively.

`getLongestTranscript.pl` is used to extract the longest transcript of each gene from the funannotate protein fasta output before running OrthoFinder and BUSCO.

`findLargestOrthogroups.pl` is used on outputs of OrthoFinder to pull the ortholog sequences from the *Danio* proteome that correspond to the largest orthogroups (default = 10) in Colorado Pikeminnow. The resulting .faa file can be submitted to the STRING database.

`findExpandedOrthogroups.pl` is used on outputs of OrthoFinder to pull the ortholog sequences from the *Danio* proteome that correspond to the orthogroups showing the greatest expansion in Colorado Pikeminnow relative to *Danio* (default multiplier = 5). The resulting .faa file can be submitted to the STRING database.
