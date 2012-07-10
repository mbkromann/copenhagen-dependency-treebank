#!/bin/bash

echo "Target Tokens for $1"

for file in data/$1/Events/*Event.xml
do
        root=${file%.Event.xml}
        tabs=${root/Events/Tables}

	echo "./Trl2EventTables.pl -T $file -O $tabs"
        ./Trl2ProgGraphTables.pl -T $file -O $tabs

	echo "./Trl2TargetTokenTables.pl -T $tabs.tt"
	./Trl2TargetTokenTables.pl -T $file > $tabs.tt

        echo "./Trl2TargetAUTables.pl -T $file >> $tabs.au"
        ./Trl2TargetAUTables.pl -T $file > $tabs.au

done    
