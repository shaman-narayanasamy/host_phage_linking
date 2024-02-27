#! /bin/bash -l 

TABLE=$1

FOLDER=$(basename -s '.tsv' $TABLE)
echo "$FOLDER"

mkdir -p tmp

cat $TABLE | tail -n +2 | cut -f1 | xargs -I{} sh -c 'curl --output "tmp/$1.zip" "https://api.ncbi.nlm.nih.gov/datasets/v2alpha/genome/accession/$1/download?include_annotation_type=GENOME_FASTA" && unzip -d tmp/$1 tmp/$1.zip -x "*.md" "*.json" "*.jsonl" && rm "tmp/$1.zip"' sh {}

mkdir -p $FOLDER
mv tmp/* $FOLDER
rm -rf ./tmp
