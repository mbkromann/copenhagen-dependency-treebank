#!/bin/bash

echo "Copying $1 data"
for file in ../$1/Translog-II/*.xml
do
        mkdir -p data/$1/Translog-II
        echo "cp  $file data/$1/Translog-II"
        cp -r  $file data/$1/Translog-II/
done

for file in ../$1/Alignment/*.{src,tgt,atag}
do
        mkdir -p data/$1/Alignment
        echo "cp  $file data/$1/Alignment"
        cp -r  $file data/$1/Alignment/
done

