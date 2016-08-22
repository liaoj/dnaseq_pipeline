#!/bin/bash
DIR="$(basename $(readlink -f $0))"

BAM=$1
R1=$2
PU=$3
BED=$4

REF="$HOME/data/hg19/hg19.fa"
DBSNP="$HOME/data/gatk-bundle/dbsnp_138.hg19.vcf"
PHASE1_INDELS="$HOME/data/gatk-bundle/1000G_phase1.indels.hg19.sites.vcf"
STD_INDELS="$HOME/data/gatk-bundle/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf"

picard MarkDuplicates \
	INPUT=${BAM} \
	OUTPUT=dedup.bam \
	METRICS_FILE=dedup_metrics.txt

# What is read group and why we need it? See https://software.broadinstitute.org/gatk/guide/article?id=6472
# http://broadinstitute.github.io/picard/command-line-overview.html#AddOrReplaceReadGroups
picard AddOrReplaceReadGroups \
	INPUT=dedup.bam \
	OUTPUT=dedup_readgrp.bam \
	ID=${R1} \
	LB=MiSeq \
	PL=illumina \
	PU=${PU} \
	SM=${R1}

samtools index dedup_readgrp.bam

GATK -T RealignerTargetCreator \
	-R ${REF} \
	-I dedup_readgrp.bam \
	-nt ${CORES} \
	-known "$PHASE1_INDELS" \
	-known "$STD_INDELS" \
	-o targets.list

GATK -T IndelRealigner \
	-R ${REF} \
	-I dedup_readgrp.bam \
	-targetIntervals targets.list \
	-known "$PHASE1_INDELS" \
	-known "$STD_INDELS" \
	-o realign.bam

GATK -T BaseRecalibrator \
	-R ${REF} \
	-I realign.bam \
	-known "$DBSNP" \
	-known "$PHASE1_INDELS" \
	-known "$STD_INDELS" \
	-o recal_before.table

GATK -T BaseRecalibrator \
	-R ${REF} \
	-I realign.bam \
	-known "$DBSNP" \
	-known "$PHASE1_INDELS" \
	-known "$STD_INDELS" \
	-BQSR recal_before.table \
	-o recal_after.table

GATK -T AnalyzeCovariates \
	-R ${REF} \
	-before recal_before.table \
	-after recal_after.table \
	-plots recal.pdf \
	-csv recal.csv

GATK -T PrintReads \
	-R ${REF} \
	-I realign.bam \
	-BQSR recal_before.table \
	-o recal.bam

GATK -T HaplotypeCaller \
	-R ${REF} \
	-I recal.bam \
	-L ${BED} \
	--genotyping_mode DISCOVERY \
	-stand_emit_conf 10 \
	-stand_call_conf 30 \
	-o haplotype_caller.vcf

echo "Last status:"
if [ $? -eq 0 ]
then
	echo "OK"
else
	echo "Oh, no!"
fi

Rscript $DIR/remove_low_quality.R haplotype_caller.vcf
head -n 120 haplotype_caller.vcf > haplotype_caller_head_120.vcf
cat haplotype_caller_head_120.vcf haplotype_caller_end.vcf > gatk.vcf
# rm $(basename $1 .bam).vcf $(basename $1 .bam)\_start.vcf $(basename $1 .bam)\_end.vcf

# gzip $(basename $1 .bam)\_gatk.vcf

#date
