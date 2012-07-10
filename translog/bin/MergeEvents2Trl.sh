#!/bin/bash

echo "Event files for $1"

rm -rf data/$1/Events
mkdir -p data/$1/Events
for file in data/$1/Translog-II/*.xml
do
        root=${file%.xml}
        atag=${root/Translog-II/Alignment}
        outp=${root/Translog-II/Events}

	echo "./MergeAtagTrl.pl -T $file -A $atag -O $outp.Atag.xml"
	./MergeAtagTrl.pl -T $file -A $atag -O "$outp.Atag.xml"

        echo "./FixMod2Trl.pl   -T "$outp.Atag.xml" -O $outp.Event.xml"
        ./FixMod2Trl.pl -T "$outp.Atag.xml" -O  "$outp.Event.xml"

        rm -f $outp.Atag.xml

        echo "";
done    
