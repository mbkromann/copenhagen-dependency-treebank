#!/bin/bash

cd /srv/dgs2/mwh/cdtParsing/cdt/automaticAnnotation
date >> logs/en.log
./updateAutomaticAnnotations.pl en tag 2>> logs/en.log >> logs/en.log
echo "-------------------------------------------" >> logs/en.log
 