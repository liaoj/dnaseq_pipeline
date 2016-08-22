#!/bin/bash

cat $1 | java -Xmx6G -jar /home/galaxy/command_pipelines/snpEff/SnpSift.jar filter "( QUAL > 100 ) & ( DP > 6 ) & ( AN = 2 ) & ( MQ > 40 )" > temp.vcf
java -Xmx6G -jar /home/galaxy/command_pipelines/snpEff/SnpSift.jar annotate -info NONE $2 temp.vcf > $1
java -Xmx6G -jar /home/galaxy/command_pipelines/snpEff/snpEff.jar eff -i vcf -o vcf -upDownStreamLen 5000 -spliceSiteSize 2 -lof -oicr -hgvs -sequenceOntology -noLog -dataDir /home/galaxy/galaxy-master/tool-data/snpEff/v4_0/data hg19 $1 > temp.vcf
/bio01/ANNOVAR/annovar/table_annovar.pl temp.vcf /bio01/ANNOVAR/annovar/humandb/ -protocol cosmic70,clinvar_20150629,1000g2015aug_all,1000g2015aug_eas,dbnsfp30a -operation f,f,f,f,f -nastring '.' -buildver hg19 --outfile output --vcfinput
cp output.hg19_multianno.vcf $(basename $1 .vcf)\_final.vcf
rm temp.vcf
rm output*
