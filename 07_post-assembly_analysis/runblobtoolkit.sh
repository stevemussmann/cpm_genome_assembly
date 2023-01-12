#!/bin/bash

## need to install docker container
# docker pull genomehubs/blobtoolkit

## get current working directory
CWD=`pwd`

## files and species-specific information
FASTA="pluc_hic_genome.3ddna.fa"
BUSCO="full_table.tsv"
TAXID="232998" #taxid for Ptychocheilus lucius
SPECIES="pluc"

## make directories
DATASETS="$HOME/Desktop/docker/blobtoolkit/datasets"
DATA="$HOME/Desktop/docker/blobtoolkit/data"
OUT="$HOME/Desktop/docker/blobtoolkit/output"

mkdir -p $DATASETS
mkdir -p $DATA
mkdir -p $OUT
mkdir -p "$DATASETS/taxdump"

## get taxdump
#wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz -P $DATASETS/taxdump
#cd $DATASETS/taxdump
#tar -zxvf new_taxdump.tar.gz
#cd $CWD

## make dataset
docker run -it --rm --name btk -u $UID:$GROUPS -v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data \
	genomehubs/blobtoolkit:latest blobtools create --fasta /blobtoolkit/data/$FASTA \
	--taxid $TAXID --taxdump /blobtoolkit/datasets/taxdump datasets/$SPECIES

## add busco data
docker run -it --rm --name btk -u $UID:$GROUPS -v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data \
	genomehubs/blobtoolkit:latest blobtools add --busco /blobtoolkit/data/$BUSCO datasets/$SPECIES

## start viewer
#docker run -d --rm --name btk -v $DATASETS:/blobtoolkit/datasets -v $OUT:/blobtoolkit/output \
#	-p 8000:8000 -p 8080:8080 -e VIEWER=true genomehubs/blobtoolkit:latest

## open http://localhost:8080/view/all/ in firefox

## make plot
#docker exec -it btk blobtools view --host http://localhost:8080 --out output --view cumulative $SPECIES

exit
