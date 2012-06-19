#!/bin/bash

for file in data/*/Alignment/*.atag
do
        sdir=`expr "$file" : 'data/\(.*\)/Alignment/'`
        root=${file%.atag}
        sent=${file/.atag/.SentAlign}
        sent=${sent/$sdir\/Alignment\//work-dir\/${sdir}_}
        outp=${root/Alignment/Alignment\/new1}

        mkdir -p "data/${sdir}/Alignment/new1"
	echo "./SentenceAlign2Atag.pl -A $root -S $sent -O $outp"
	./SentenceAlign2Atag.pl -A $root -S $sent -O $outp

        echo "";
done    
