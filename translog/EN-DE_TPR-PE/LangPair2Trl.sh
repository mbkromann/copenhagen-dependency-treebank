#!/bin/bash

for file in Translog-II/*.xml ; do
   echo "Inserting -s en -t de into $file ";
   ../LangPair2Trl.pl -T $file -s en -t de > $file.langPair
   mv $file.langPair $file
done
