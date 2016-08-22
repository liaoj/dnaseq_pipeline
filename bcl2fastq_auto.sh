#!/bin/bash

if [ x$1 != x ]
then
    echo "Good!"
else
    echo "Please set directory!"
    exit
fi

sleep 630m

bcl2fastq --runfolder-dir $1 --create-fastq-for-index-reads --min-log-level INFO -r 6 -d 6 -p 12 -w 6
