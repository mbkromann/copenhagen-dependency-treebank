#!/bin/bash

mkdir -p data/Merged
for file in data/$1/Translog-II/*.xml
do
        sdir=`expr "$file" : 'data/\(.*\)/Translog-II'`
        root=${file%.xml}
        atag=${root/Translog-II/Alignment}
        outp=${root/$sdir}
        outp=${outp/\/Translog-II\//"Merged/${sdir}_"}
        trex=${root/FixMod/Treex}

	echo "./MergeAtagTrl.pl -T $file -A $atag -O $outp.Atag.xml"
	./MergeAtagTrl.pl -T $file -A $atag -O "$outp.Atag.xml"

        echo "./FixMod2Trl.pl   -T "$outp.Atag.xml" -O $outp.Event.xml"
        ./FixMod2Trl.pl -T "$outp.Atag.xml" -O  "$outp.Event.xml"

#        echo "./PU-FU2Trl.pl.pl -T $outp.Event.xml > $outp.Units.xml"
#        ./PU-FU2Trl.pl -T "$outp.Event.xml" > $outp.Units.xml

#        echo "./Trl2Treex.pl    -T $outp.Units.xml -O $outp.treex.gz"
#        ./Trl2Treex.pl -T $outp.Units.xml -O $outp
        echo "";
done    
