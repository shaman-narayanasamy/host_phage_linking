#! /bin/bash -l 

TABLE=$1

## Load the bvbrc table
FOLDER=$(basename -s '.txt' $TABLE | cut -f1 -d'-')
echo "$FOLDER"

mkdir -p tmp

cut -f42 $TABLE | grep -v '^[[:space:]]*$' | tail -n +2 | sed -e 's/"//g' | xargs -I{} sh -c 'curl --output "tmp/$1.zip" "https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/$1/download?include_annotation_type=GENOME_FASTA" && unzip -d tmp/$1 tmp/$1.zip -x "*.md" "*.json" "*.jsonl" && rm "tmp/$1.zip"' sh {}

mkdir -p $FOLDER
mv tmp/* $FOLDER
rm -rf ./tmp
