#!/bin/bash

cd /srv/dgs2/mwh/cdtParsing/cdt/automaticAnnotation
date >> logs/it.log
./updateAutomaticAnnotations.pl it 2>> logs/it.log >> logs/it.log
echo "-------------------------------------------" >> logs/it.log
 