#! /bin/bash -l

module load singularity

APPDIR='/home/naras0c/repositories/github/CRISPRCasFinder'
IMAGE='/home/naras0c/repositories/github/CRISPRCasFinder/CrisprCasFinder.simg'
INPUT=$1
OUTDIR=$2
TMP_WORKDIR=$3
THREADS=$4

mkdir -p "$OUTDIR"
mkdir -p "$TMP_WORKDIR"  # 🔹 Ensure the temp workdir exists!

INPUT_BASEDIR=$(dirname "$INPUT")
INPUT_FILENAME=$(basename "$INPUT")
#OUTPUT_BASENAME=$(basename "$INPUT_BASEDIR")
OUTPUT_BASENAME=$(basename "$INPUT_FILENAME")
OUTPUT_BASENAME="${OUTPUT_BASENAME%.fasta}"
OUTPUT_BASENAME="${OUTPUT_BASENAME%.fas}"
OUTPUT_BASENAME="${OUTPUT_BASENAME%.fna}"
echo "$name"

echo $OUTDIR
echo $INPUT_BASEDIR
echo $INPUT_FILENAME
echo $OUTPUT_BASENAME

singularity exec -B $APPDIR \
	--no-home \
	-B /ibex/user/naras0c/:/mnt \
	-B $INPUT_BASEDIR:/input \
	-B $OUTDIR:/output \
        -B $TMP_WORKDIR:/workdir \
	$IMAGE  bash -c "
    cd /workdir || exit 1
    perl /usr/local/CRISPRCasFinder/CRISPRCasFinder.pl \
        -so /usr/local/CRISPRCasFinder/sel392v2.so \
        -cf /usr/local/CRISPRCasFinder/CasFinder-2.0.3 \
        -drpt /usr/local/CRISPRCasFinder/supplementary_files/repeatDirection.tsv \
        -rpts /usr/local/CRISPRCasFinder/supplementary_files/Repeat_List.csv \
        -cas -def G -cpuP $THREADS -out /output/$OUTPUT_BASENAME -in /input/$INPUT_FILENAME
    "
#	perl /usr/local/CRISPRCasFinder/CRISPRCasFinder.pl \
#	-so /usr/local/CRISPRCasFinder/sel392v2.so \
#	-cf /usr/local/CRISPRCasFinder/CasFinder-2.0.3 \
#	-drpt /usr/local/CRISPRCasFinder/supplementary_files/repeatDirection.tsv \
#	-rpts /usr/local/CRISPRCasFinder/supplementary_files/Repeat_List.csv \
#	-cas -def G -cpuP $THREADS -out /output/$OUTPUT_BASENAME -in /input/$INPUT_FILENAME
