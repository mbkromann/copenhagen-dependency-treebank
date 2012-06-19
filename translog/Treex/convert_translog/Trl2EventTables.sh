#!/bin/bash

mkdir -p data/Event
for file in data/Merged/*Event.xml
do
        root=${file%.Event.xml}
        event=${root/Merged/Event}

	echo "./Trl2EventTables.pl -T $file -O $event"
	./Trl2EventTables.pl -T $file -O $event
done    
