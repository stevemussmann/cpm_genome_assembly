#!/bin/bash

## need to install docker container
# docker pull genomehubs/blobtoolkit

CWD=`pwd`
DATASETS="$CWD/datasets"
DATA="$CWD/data"
OUTPUT="$CWD/output"
TAXDUMP="$CWD/taxdump"

## HIFIASM DETAILS
FASTA="pluc_hic_genome.fa"
BAM="pluc_hic_genome.bam"
D="hifiasm"

## 3DDNA DETAILS
FASTA2="pluc_hic_genome.3ddna.fa"
BAM2="pluc_hic_genome.3ddna.bam"
D2="3d-dna"

## DETAILS FOR ALL
TAXID="232998" #Genbank taxid for Ptychocheilus lucius
IMG="btk"

mkdir -p $DATASETS
mkdir -p $DATA
mkdir -p $OUTPUT
mkdir -p $TAXDUMP

## get taxdump
#wget https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/new_taxdump/new_taxdump.tar.gz -P $TAXDUMP	
#cd $TAXDUMP
#tar -zxvf new_taxdump.tar.gz
#cd $CWD

## dummy file to make cumulative plots work
HITS="blank.hits.out"
touch $OUTPUT/$HITS

# get rid of docker image and datasets if they already exist
sudo docker rm -f $IMG
rm -rf $DATASETS/$D
rm -rf $DATASETS/$D2

## COMMANDS FOR HIFIASM OUTPUT
# create dataset
sudo docker run -it --rm --name $IMG -u $UID:$GROUPS \
	-v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data -v $TAXDUMP:/blobtoolkit/taxdump \
	genomehubs/blobtoolkit:latest \
	blobtools create \
	--fasta data/$FASTA \
	--taxid $TAXID \
	--taxdump taxdump \
	datasets/$D

# add busco data
sudo docker run -it --rm --name $IMG -u $UID:$GROUPS \
	-v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data -v $TAXDUMP:/blobtoolkit/taxdump \
	genomehubs/blobtoolkit:latest \
	blobtools add --busco data/busco/contigs/actinopterygii/pluc_busco/run_actinopterygii_odb10/full_table.tsv \
	datasets/$D

# uncomment lines below to add vertebrata busco results instead of actinopterygii
sudo docker run -it --rm --name $IMG -u $UID:$GROUPS \
	-v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data -v $TAXDUMP:/blobtoolkit/taxdump \
	genomehubs/blobtoolkit:latest \
	blobtools add --busco data/busco/contigs/vertebrata/pluc_busco/run_vertebrata_odb10/full_table.tsv \
	datasets/$D

# add coverage data
sudo docker run -it --rm --name $IMG -u $UID:$GROUPS \
	-v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data -v $TAXDUMP:/blobtoolkit/taxdump \
	genomehubs/blobtoolkit:latest \
	blobtools add --cov data/coverage/minimap2/contigs/$BAM \
	datasets/$D

## COMMANDS FOR 3DDNA OUTPUT
# create dataset
sudo docker run -it --rm --name $IMG -u $UID:$GROUPS \
	-v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data -v $TAXDUMP:/blobtoolkit/taxdump \
	genomehubs/blobtoolkit:latest \
	blobtools create \
	--fasta data/$FASTA2 \
	--taxid $TAXID \
	--taxdump taxdump \
	datasets/$D2

# add busco data
sudo docker run -it --rm --name $IMG -u $UID:$GROUPS \
	-v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data -v $TAXDUMP:/blobtoolkit/taxdump \
	genomehubs/blobtoolkit:latest \
	blobtools add --busco data/busco/3ddna/actinopterygii/pluc_busco/run_actinopterygii_odb10/full_table.tsv \
	datasets/$D2

# uncomment lines below to add vertebrata busco results instead of actinopterygii
sudo docker run -it --rm --name $IMG -u $UID:$GROUPS \
	-v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data -v $TAXDUMP:/blobtoolkit/taxdump \
	genomehubs/blobtoolkit:latest \
	blobtools add --busco data/busco/3ddna/vertebrata/pluc_busco/run_vertebrata_odb10/full_table.tsv \
	datasets/$D2

# add coverage data
sudo docker run -it --rm --name $IMG -u $UID:$GROUPS \
	-v $DATASETS:/blobtoolkit/datasets -v $DATA:/blobtoolkit/data -v $TAXDUMP:/blobtoolkit/taxdump \
	genomehubs/blobtoolkit:latest \
	blobtools add --cov data/coverage/minimap2/3ddna/$BAM2 \
	datasets/$D2

## START DOCKER VIEWER INSTANCE - only needs to be done once
sudo docker run -d --rm --name $IMG -v $DATASETS:/blobtoolkit/datasets -v $TAXDUMP:/blobtoolkit/taxdump \
	-v $OUTPUT:/blobtoolkit/output -p 8000:8000 -p 8080:8080 \
	-e VIEWER=true genomehubs/blobtoolkit:latest

## MAKE PLOTS FOR HIFIASM OUTPUT
# add dummy file so cumulative plot should work
sudo docker exec -it $IMG \
	blobtools add --hits output/$HITS \
	--taxdump taxdump \
	datasets/$D

# make cumulative plot
sudo docker exec -it $IMG \
	blobtools view --host http://localhost:8080 --out output \
	--view cumulative $D

# make snail plot
sudo docker exec -it $IMG \
	blobtools view --host http://localhost:8080 --out output \
	--view snail $D

## MAKE PLOTS FOR 3DDNA OUTPUT
# add dummy file so cumulative plot should work
sudo docker exec -it $IMG \
	blobtools add --hits output/$HITS \
	--taxdump taxdump \
	datasets/$D2

# make cumulative plot
sudo docker exec -it $IMG \
	blobtools view --host http://localhost:8080 --out output \
	--view cumulative $D2

# make snail plot
sudo docker exec -it $IMG \
	blobtools view --host http://localhost:8080 --out output \
	--view snail $D2

exit
