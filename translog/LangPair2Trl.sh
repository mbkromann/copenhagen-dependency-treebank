#!/bin/bash

for file in */Translog-II/*.xml ; do
   LangPair2Trl.pl -T $file -s en -t da > $file.langPair
   mv $file.langPair $file
done
