#!/bin/bash
VCF=$1
CLINVAR=$2

snpSift filter "( QUAL > 100 ) & ( DP > 6 ) & ( AN = 2 ) & ( MQ > 40 )" "${VCF}" > filterd.vcf
snpSift annotate -info NONE "${CLINVAR}" filterd.vcf > annotated.vcf

snpEff eff -i vcf -o vcf -upDownStreamLen 5000 -spliceSiteSize 2 -lof -oicr -hgvs -sequenceOntology -noLog -dataDir /home/galaxy/galaxy-master/tool-data/snpEff/v4_0/data hg19 ${VCF} > snpEff.vcf

/bio01/ANNOVAR/annovar/table_annovar.pl snpEff.vcf /bio01/ANNOVAR/annovar/humandb/ -protocol cosmic70,clinvar_20150629,1000g2015aug_all,1000g2015aug_eas,dbnsfp30a -operation f,f,f,f,f -nastring '.' -buildver hg19 --outfile output --vcfinput

# cp $(basename $1 .fastq.gz)output.hg19_multianno.vcf $(basename $1 .vcf)\_final.vcf
# rm $(basename $1 .fastq.gz)temp.vcf
# rm $(basename $1 .fastq.gz)output*
