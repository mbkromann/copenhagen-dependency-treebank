#!/bin/bash

echo "Target Tokens for $1"

rm -rf   data/$1/Tables
mkdir -p data/$1/Tables

for file in data/$1/Events/*Event.xml
do
        root=${file%.Event.xml}
        tabs=${root/Events/Tables}

	echo "Token Tables -T $file -O $tabs.{st,tt,fd,kd,pu,fu,au}"
        ./Trl2ProgGraphTables.pl -T $file -O $tabs

#	echo "./Trl2TargetTokenTables.pl -T $tabs.tt"
	./Trl2TargetTokenTables.pl -T $file > $tabs.tt

#        echo "./Trl2TargetAUTables.pl -T $file > $tabs.au"
        ./Trl2TargetAUTables.pl -T $file > $tabs.au

done    
