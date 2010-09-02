#!/bin/bash

date >> logs/en.log
./updateAutomaticAnnotations.pl en 2>> logs/en.log >> logs/en.log
echo "-------------------------------------------" >> logs/en.log
 