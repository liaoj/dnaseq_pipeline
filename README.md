# Requirement Installations

## Common Dependencies

Install common dependencies on Ubuntu 14.04:

```bash
sudo apt-get update
sudo apt-get install unzip pigz xterm tmux git g++ make libcurl3 libncurses5-dev zlib1g-dev libcurl4-openssl-dev default-jdk r-base-dev
```

## Java 8

GenomeAnalysisTK-3.6 depends on Java 8. Install Java 8 on Ubuntu 14.04:

```bash
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get install oracle-java8-installer
java -version
```

## Working Directories

Create working directories for data processing:

```bash
mkdir $HOME/build  # tool path
mkdir $HOME/local  # install path
mkdir $HOME/data   # dataset path
```

## Datasets

### Reference Genome

Download reference genome hg19:

```bash
mkdir $HOME/data/hg19 && cd $HOME/data/hg19
wget http://hgdownload.cse.ucsc.edu/goldenPath/hg19/bigZips/chromFa.tar.gz
tar zxf chromFa.tar.gz
cat chr1.fa chr2.fa chr3.fa chr4.fa chr5.fa chr6.fa chr7.fa chr8.fa chr9.fa chr10.fa chr11.fa chr12.fa chr13.fa chr14.fa chr15.fa chr16.fa chr17.fa chr18.fa chr19.fa chr20.fa chr21.fa chr22.fa chrX.fa chrY.fa chrM.fa > hg19.fa
```

### Generate index

Prepare a reference for use with BWA and GATK:

```bash
cd $HOME/data/hg19
bwa index -a bwtsw -p hg19 hg19.fa    # Generate the BWA index
samtools faidx hg19.fa                # Generate the fasta file index
picard CreateSequenceDictionary REFERENCE=hg19.fa OUTPUT=hg19.dict  # Generate the sequence dictionary
```

### VCF Data

```bash
mkdir $HOME/data/gatk-bundle && cd $HOME/data/gatk-bundle
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/2.8/hg19/dbsnp_138.hg19.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/2.8/hg19/dbsnp_138.hg19.vcf.idx.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/2.8/hg19/1000G_phase1.indels.hg19.sites.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/2.8/hg19/1000G_phase1.indels.hg19.sites.vcf.idx.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/2.8/hg19/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.gz
wget ftp://gsapubftp-anonymous@ftp.broadinstitute.org/bundle/2.8/hg19/Mills_and_1000G_gold_standard.indels.hg19.sites.vcf.idx.gz
ls -1 *.gz | xargs gunzip
```

## Bioinformatics Tools

### trimmomatic

```bash
cd $HOME/build
wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.36.zip
unzip Trimmomatic-0.36.zip && cd Trimmomatic-0.36
echo "java -jar $PWD/trimmomatic-0.36.jar \$@" > trimmomatic
chmod +x trimmomatic
ln -sf $PWD/trimmomatic $HOME/local/bin
```

### fastqc

```bash
cd $HOME/build
wget http://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.5.zip
unzip fastqc_v0.11.5.zip && cd FastQC
chmod +x fastqc
ln -sf $PWD/fastqc $HOME/local/bin
```

### bwa

```bash
cd $HOME/build
wget https://github.com/lh3/bwa/releases/download/v0.7.15/bwa-0.7.15.tar.bz2
tar jxf bwa-0.7.15.tar.bz2 && cd bwa-0.7.15
make
ln -sf $PWD/bwa $HOME/local/bin
```

### samtools

```bash
cd $HOME/build
wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2
tar jxf samtools-1.3.1.tar.bz2 && cd samtools-1.3.1
./configure --enable-plugins --enable-libcurl --prefix=$HOME/local
make install
```

### picard

```bash
cd $HOME/build
wget https://github.com/broadinstitute/picard/releases/download/1.140/picard-tools-1.140.zip
unzip picard-tools-1.140.zip && cd picard-tools-1.140
echo "java -jar $PWD/picard.jar \$@" > picard
chmod +x picard
ln -sf $PWD/picard $HOME/local/bin
```

### SnpEff & SnpSift

```bash
cd $HOME/build
wget http://downloads.sourceforge.net/project/snpeff/snpEff_latest_core.zip
unzip snpEff_latest_core.zip && cd snpEff/
echo "java -jar $PWD/snpEff.jar \$@" > snpEff
echo "java -jar $PWD/SnpSift.jar \$@" > snpSift
chmod +x snpEff snpSift
ln -sf $PWD/snpEff $HOME/local/bin
ln -sf $PWD/snpSift $HOME/local/bin
```

### GATK

Register and download GenomeAnalysisTK-3.6 from [this link](https://software.broadinstitute.org/gatk/download) to directory `$HOME/build`.

```bash
cd $HOME/build
mkdir GenomeAnalysisTK-3.6 && cd GenomeAnalysisTK-3.6
tar jxf ../GenomeAnalysisTK-3.6.tar.bz2
echo "java -jar $PWD/GenomeAnalysisTK.jar \$@" > GATK
chmod +x GATK
ln -sf $PWD/GATK $HOME/local/bin
```

# Data Processing Pipeline

[Read and run this script](pipeline_for_targeted_exons_using_GATK_from_MiSeq.sh).
