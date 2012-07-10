#!/bin/bash

echo "Progression Graphs for $1"

mkdir -p data/$1/ProgGraph
for file in data/$1/Events/*Event.xml
do
        root=${file%.Event.xml}
        event=${root/Events/ProgGraph}

	echo "./Trl2EventTables.pl -T $file -O $event"
	./Trl2ProgGraphTables.pl -T $file -O $event
done    
