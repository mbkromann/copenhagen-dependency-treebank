#!/bin/bash

for file in data/*/* ; do
   cat $file | iconv -f iso-8859-1 -t utf8 > $file.utf8
done
