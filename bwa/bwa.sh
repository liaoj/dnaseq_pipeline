#!/bin/sh
R1=$1
R2=$1
SAM=$3
BAM=$4

bwa mem -t ${CORES} $HOME/data/hg19/hg19 ${R1} ${R2} > ${SAM}
pigz -3 -p ${CORES} -- ${SAM} # output to ${SAM}.gz

samtools view -@ ${CORES} -S -b ${SAM}.gz | samtools sort -@ ${CORES} -o ${BAM}
samtools index ${BAM}
