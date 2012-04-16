#!/bin/bash

 
for file in *{src,tgt} ; do
   cat $file | iconv -f iso-8859-1 -t utf8 > $file.utf8
   mv $file.utf8 $file
done
