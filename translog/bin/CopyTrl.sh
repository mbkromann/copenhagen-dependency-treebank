#!/bin/bash

echo "Copying $1 data"
rm -rf data/$1/Translog-II/*.xml 
rm -rf data/$1/Alignment/*.{src,tgt,atag}
mkdir -p data/$1/Translog-II
mkdir -p data/$1/Alignment

for file in ../$1/Translog-II/*.xml
do
        echo "cp  $file data/$1/Translog-II"
        cp -r  $file data/$1/Translog-II/
done

for file in ../$1/Alignment/*.{src,tgt,atag}
do
        echo "cp  $file data/$1/Alignment"
        cp -r  $file data/$1/Alignment/
done

