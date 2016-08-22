#!/bin/bash
TRIMPATH=$HOME/build/Trimmomatic-0.36
R1=$1
R2=$2
T1=$3
T2=$4

trimmomatic PE -phred33 -threads ${CORES} \
	$R1 $R2 \
	$T1 /dev/null \
	$T2 /dev/null \
	ILLUMINACLIP:$TRIMPATH/adapters/TruSeq3-PE-2.fa:2:30:10 \
	LEADING:20 TRAILING:20 MINLEN:280 CROP:280
