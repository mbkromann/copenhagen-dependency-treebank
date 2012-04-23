#!/bin/bash

for file in Translog-II/*.xml ; do
   echo "Inserting -s en -t pt into $file ";
   ../LangPair2Trl.pl -T $file -s en -t pt > $file.langPair
   mv $file.langPair $file
done
