#!/bin/bash


mkdir -p data/Treex
for file in data/Merged/*Event.xml
do
        treex=${file%.xml}
        treex=${root/Merged/Treex}

#	echo "./MergeAtagTrl.pl -T $file -A $atag -O $outp.Atag.xml"
#	./MergeAtagTrl.pl -T $file -A $atag -O "$outp.Atag.xml"
#
#        echo "./FixMod2Trl.pl   -T "$outp.Atag.xml" -O $outp.Event.xml"
#        ./FixMod2Trl.pl -T "$outp.Atag.xml" -O  "$outp.Event.xml"
#
#        echo "./PU-FU2Trl.pl.pl -T $outp.Event.xml > $outp.Units.xml"
#        ./PU-FU2Trl.pl -T "$outp.Event.xml" > $outp.Units.xml

        echo "./Trl2Treex.pl  -T $file -O $treex"
        ./Trl2Treex.pl -T $file -O $treex
        echo "";
done    
