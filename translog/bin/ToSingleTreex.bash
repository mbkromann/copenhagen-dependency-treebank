#!/bin/bash

if [ "$1" == "" ]; then
  echo "$0 Study_Name "
  exit 
fi
 

mkdir -p data/Treex/raw
for file in data/$1/Events/*Event.xml
do
        root=${file%.Event.xml}
        root=`expr "$root" : '.*/\(.*\)'` 

        echo "./Trl2Treex.pl  -T $file -O data/Treex/raw/$1-$root"
        ./Trl2Treex.pl -T $file -O "data/Treex/raw/$1-$root"
done    
