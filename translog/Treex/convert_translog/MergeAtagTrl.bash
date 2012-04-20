#!/bin/bash

mkdir -p data/Merged

for file in data/*/Translog-II/*.xml
do
        sdir=`expr "$file" : 'data/\(.*\)/Translog-II'`
        abcd=${file%.xml}
        atag=${abcd/Translog-II/Alignment}
        outp=${file/$sdir}
        outp=${outp/\/Translog-II\//"Merged/${sdir}_"}
	echo "./MergeAtagTrl.pl -T $file -A $atag -O $outp"
	./MergeAtagTrl.pl -T $file -A $atag -O$outp
done
