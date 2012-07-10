#!/bin/bash

 
for file in *{atag,tgt} ; do
   cat $file | iconv -t iso-8859-1 -f utf8 > singleUTF/$file
done
