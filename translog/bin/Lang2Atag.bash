#!/bin/bash

path="/home/critt/cdt-all/trunk/translog/bin"

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
  echo "$0 Path Source Target "
  exit
fi

for file in $1/Alignment/*.atag ; do
   root=${file%.atag}

   $path/Lang2Atag.pl -A $root -s $2 -t $3 -f1 > $root.src.lang
   $path/Lang2Atag.pl -A $root -s $2 -t $3 -f2 > $root.tgt.lang
   $path/Lang2Atag.pl -A $root -s $2 -t $3 -f3 > $root.atag.lang
done
rename -f 's/.lang$//' $1/Alignment/*.lang
