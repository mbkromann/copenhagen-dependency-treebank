#!/bin/bash

echo "Target AU Tables for $1"

for file in data/$1/Events/*Event.xml
do
        root=${file%.Event.xml}

	echo "./Trl2TargetAUTables.pl -T $file >> data/TargetAUTables.tsv"
	./Trl2TargetAUTables.pl -T $file >> data/TargetAUTables.tsv
done    
