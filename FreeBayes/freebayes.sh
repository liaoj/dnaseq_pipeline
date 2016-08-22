#!/bin/bash

#date

java -Xmx6G -jar /home/galaxy/command_pipelines/picard-tools-1.137/picard.jar MarkDuplicates \
	INPUT=$1 \
	OUTPUT=$(basename $1 .bam)\_md.bam \
	METRICS_FILE=$(basename $1 .bam)\_metrics.txt

mv $(basename $1 .bam)\_md.bam $(basename $1 .bam)\_$2.bam

java -Xmx6G -jar /home/galaxy/command_pipelines/picard-tools-1.137/picard.jar AddOrReplaceReadGroups \
	INPUT=$(basename $1 .bam)\_$2.bam \
	OUTPUT=$(basename $1 .bam)\_md.bam \
	ID=$(basename $1 .bam) \
	LB=MiSeq \
	PL=illumina \
	PU=$2 \
	SM=$(basename $1 .bam)

rm $(basename $1 .bam)\_$2.bam

/home/galaxy/command_pipelines/samtools/samtools-1.2/samtools index $(basename $1 .bam)\_md.bam

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T RealignerTargetCreator \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_md.bam \
	-nt 8 \
	-known /bio01/Downloads/bundle/1000G_phase1.indels.hg19.sites.vcf \
	-known /bio01/Downloads/bundle/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-o $(basename $1 .bam)\_targets.list

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T IndelRealigner \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_md.bam \
	-targetIntervals $(basename $1 .bam)\_targets.list \
	-known /bio01/Downloads/bundle/1000G_phase1.indels.hg19.sites.vcf \
	-known /bio01/Downloads/bundle/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-o $(basename $1 .bam)\_realign.bam

rm $(basename $1 .bam)\_md.bam
rm $(basename $1 .bam)\_md.bam.bai

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_realign.bam \
	-knownSites /bio01/Downloads/bundle/dbsnp_138.hg19.vcf \
	-knownSites /bio01/Downloads/bundle/1000G_phase1.indels.hg19.sites.vcf \
	-knownSites /bio01/Downloads/bundle/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-o $(basename $1 .bam)\_recal.table

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T BaseRecalibrator \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_realign.bam \
	-knownSites /bio01/Downloads/bundle/dbsnp_138.hg19.vcf \
	-knownSites /bio01/Downloads/bundle/1000G_phase1.indels.hg19.sites.vcf \
	-knownSites /bio01/Downloads/bundle/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf \
	-BQSR $(basename $1 .bam)\_recal.table \
	-o $(basename $1 .bam)\_post\_recal.table

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T AnalyzeCovariates \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-before $(basename $1 .bam)\_recal.table \
	-after $(basename $1 .bam)\_post\_recal.table \
	-plots $(basename $1 .bam)\_recal.pdf \
	-csv $(basename $1 .bam)\_recal.csv

java -Xmx6G -jar /home/galaxy/command_pipelines/GATK/GenomeAnalysisTK.jar \
	-T PrintReads \
	-R /bio01/Downloads/ucsc.hg19.fasta \
	-I $(basename $1 .bam)\_realign.bam \
	-BQSR $(basename $1 .bam)\_recal.table \
	-o $(basename $1 .bam)\_recal.bam

rm $(basename $1 .bam)\_realign.bam
rm $(basename $1 .bam)\_realign.bai

/home/galaxy/command_pipelines/FreeBayes/freebayes/bin/freebayes \
	$(basename $1 .bam)\_recal.bam \
	--no-mnps \
	-F 0.01 \
	--haplotype-length 30 \
	--targets $3 \
	-f /bio01/Downloads/ucsc.hg19.fasta \
	--vcf $(basename $1 .bam)\_freebayes.vcf

rm $(basename $1 .bam)\_recal.bam
rm $(basename $1 .bam)\_recal.bai

#date

#	backup
#	| /home/galaxy/command_pipelines/ogap/ogap/ogap -z -R 25 -C 20 -Q 20 -S 0 -f /home/galaxy/galaxy-master/tool-data/hg19/seq/hg19.fa \
#	| /home/galaxy/command_pipelines/FreeBayes/freebayes/bin/bamleftalign -f /home/galaxy/galaxy-master/tool-data/hg19/seq/hg19.fa \
#	| /home/galaxy/command_pipelines/samtools/samtools-1.2/samtools calmd -EAru - /home/galaxy/galaxy-master/tool-data/hg19/seq/hg19.fa 2>/dev/null \
#	| /home/galaxy/command_pipelines/vcflib/vcflib/bin/vcffilter -f "(QUAL > 30)&(DP > 25)" \
#	| pigz -p 8 > $(basename $1 .bam).vcf.gz
