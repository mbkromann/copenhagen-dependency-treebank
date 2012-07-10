#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
  echo "Source and target languages required"
  exit
fi


for file in Translog-II/*.xml ; do
   ../bin/LangPair2Trl.pl -T $file -s $1 -t $2 > $file.langPair
   mv $file.langPair $file
done
