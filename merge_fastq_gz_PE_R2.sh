#!/bin/bash

sleep 900m

starttime=`date`
echo $starttime

for i in {1..80}
do
    for j in $i\_S*R2\_001.fastq.gz
    do
        pigz -p 12 -dc <$j >${j%.gz}
    done
    cat $i\_S*R2\_001.fastq | pigz -p 12 -n -9 >$i\_R2\_001.fastq.gz
    rm -f $i\_S*R2\_001.fastq
done

endtime=`date`
echo $endtime
