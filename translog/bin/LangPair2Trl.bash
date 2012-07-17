#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ] || [$3 == "" ]; then
  echo "$0 Path source target "
  exit
fi


for file in $1/Translog-II/*.xml ; do
   bin/LangPair2Trl.pl -T $file -s $2 -t $3 > $file.langPair
done
rename -f 's/.langPair//' *.langPair
