#!/bin/bash

date >> logs/de.log
./updateAutomaticAnnotations.pl de 2>> logs/de.log >> logs/de.log
echo "-------------------------------------------" >> logs/de.log
 