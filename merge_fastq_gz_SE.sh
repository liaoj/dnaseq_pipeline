#!/bin/bash

starttime=`date`
echo $starttime

for i in {1..80}
do
    for j in $i\_S*.fastq.gz
    do
        pigz -p 12 -dc <$j >${j%.gz}
    done
    cat $i\_S*.fastq | pigz -p 24 -n -9 >$i\_R1.fastq.gz
    rm -f $i\_S*.fastq
done

endtime=`date`
echo $endtime
