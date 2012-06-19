#!/bin/bash

	echo $1
#rm -r data/$1
for file in ../../{Annette_translate,EN-DA,ED12,EN-DE_TPR-PE,EN-ES,EN-HI,EN-PT_TPR-PE,EN-ZH,L1L2}/Translog-II/*.xml
do
	sdir=`expr "$file" : '../../\(.*\)/Translog-II'`
        mkdir -p data/${sdir}/Translog-I
        echo "cp  $file data/${sdir}/Translog-II"
        cp -r  $file data/${sdir}/Translog-II/
done

for file in ../../{Annette_translate,EN-DA,ED12,EN-DE_TPR-PE,EN-ES,EN-HI,EN-PT_TPR-PE,EN-ZH,L1L2}/Alignment/*.{src,tgt,atag}
do
	sdir=`expr "$file" : '../../\(.*\)/Alignment'`
        mkdir -p data/${sdir}/Alignment
        echo "cp  $file data/${sdir}/Alignment"
        cp -r  $file data/${sdir}/Alignment/
done

