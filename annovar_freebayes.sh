#!/bin/bash

cat $1 | java -Xmx6G -jar /home/galaxy/command_pipelines/snpEff/SnpSift.jar filter "( QUAL > 100 ) & ( DP > 6 ) & ( AN = 2 ) & ( DPB > 25 )" > $(basename $1 .fastq.gz)temp.vcf
java -Xmx6G -jar /home/galaxy/command_pipelines/snpEff/SnpSift.jar annotate -info NONE $2 $(basename $1 .fastq.gz)temp.vcf > $1
java -Xmx6G -jar /home/galaxy/galaxy-master/tools/snpEff/4.0/iuc/package_snpeff_4_0/792d8f4485fb/snpEff.jar eff -i vcf -o vcf -upDownStreamLen 5000 -spliceSiteSize 2 -lof -oicr -hgvs -sequenceOntology -noLog -dataDir /home/galaxy/galaxy-master/tool-data/snpEff/v4_0/data hg19 $1 > $(basename $1 .fastq.gz)temp.vcf
/bio01/ANNOVAR/annovar/table_annovar.pl $(basename $1 .fastq.gz)temp.vcf /bio01/ANNOVAR/annovar/humandb/ -protocol cosmic70,clinvar_20150629,1000g2015aug_all,1000g2015aug_eas,dbnsfp30a -operation f,f,f,f,f -nastring '.' -buildver hg19 --outfile $(basename $1 .fastq.gz)output --vcfinput
cp $(basename $1 .fastq.gz)output.hg19_multianno.vcf $(basename $1 .vcf)\_final.vcf
rm $(basename $1 .fastq.gz)temp.vcf
rm $(basename $1 .fastq.gz)output*
