#!/bin/bash

cd /srv/dgs2/mwh/cdtParsing/cdt/automaticAnnotation
date >> logs/de.log
./updateAutomaticAnnotations.pl de tag 2>> logs/de.log >> logs/de.log
echo "-------------------------------------------" >> logs/de.log
 