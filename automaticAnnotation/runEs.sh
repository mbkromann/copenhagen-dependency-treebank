#!/bin/bash

cd /srv/dgs2/mwh/cdtParsing/cdt/automaticAnnotation
date >> logs/es.log
./updateAutomaticAnnotations.pl es 2>> logs/es.log >> logs/es.log
echo "-------------------------------------------" >> logs/es.log
 