#!/bin/bash
DIR="$(basename $(readlink -f $0))"

# $1 is R1 reads, $2 is R2 reads
R1="$(readlink -f $1)"
R2="$(readlink -f $1)"
RD="$(basename $(basename ${R1} .gz) .fastq)"
# $3 is platform unit, $4 is bed file, $5 is clinvar vcf file.
PU="$3"
BED="$4"
CLINVAR="$5"

export CORES=$(grep 'core id' /proc/cpuinfo | wc -l)

# create a working dir
mkdir -v ${RD} && cd ${RD}

# Trim
$DIR/trimmomatic.sh "${R1}" "${R2}" R1_trimmed.fastq.gz R2_trimmed.fastq.gz

# BWA
$DIR/bwa/bwa.sh R1_trimmed.fastq.gz R2_trimmed.fastq.gz bwa.sam sorted.bam

# GATK
$DIR/GATK/gatk.sh sorted.bam "${R1}" "${PU}" "${BED}"

# Annotation
$DIR/annovar_gatk.sh gatk.vcf "${CLINVAR}"

# Preparing for extracting information and drawing plots
# mkdir -p results
# mv $(basename $1 .fastq.gz)\_trimmed\_sorted\_gatk\_final.vcf results/
# /home/galaxy/command_pipelines/samtools/samtools-1.2/samtools bedcov $4 *sorted.bam > bases.txt
# mv bases.txt results/
# mv $(basename $1 .fastq.gz)*.pdf results/
# #rm $(basename $1 .fastq.gz)*trimmed* $(basename $2 .fastq.gz)*trimmed*
# rm snpEff*
