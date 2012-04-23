#!/bin/bash

for file in Translog-II/*.xml ; do
   echo "Inserting -s en -t hi into $file ";
   ../LangPair2Trl.pl -T $file -s en -t hi > $file.langPair
   mv $file.langPair $file
done
