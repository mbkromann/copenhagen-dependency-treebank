#!/bin/bash

mkdir -p data/{Annette_translate,EN-DA,ED12,EN-DE_TPR-PE,EN-ES,EN-HI,EN-PT_TPR-PE,EN-ZH,L1L2}/Events
#for file in data/{Annette_translate,EN-DA,ED12,EN-DE_TPR-PE,EN-ES,EN-HI,EN-PT_TPR-PE,EN-ZH,L1L2}/Translog-II/*.xml
for file in data/{Annette_translate,EN-DA,ED12,EN-ES}/Translog-II/*.xml
do
        sdir=`expr "$file" : 'data/\(.*\)/Translog-II'`
        root=${file%.xml}
        atag=${root/Translog-II/Alignment}
        outp=${root/Translog-II/Events}
#        outp=${outp/\/Translog-II\//"Merged/${sdir}_"}
#        outp=${root/$sdir}
#        outp=${outp/\/Translog-II\//"Merged/${sdir}_"}
#        trex=${root/FixMod/Treex}

	echo "./MergeAtagTrl.pl -T $file -A $atag -O $outp.Atag.xml"
	./MergeAtagTrl.pl -T $file -A $atag -O "$outp.Atag.xml"

        echo "./FixMod2Trl.pl   -T "$outp.Atag.xml" -O $outp.Event.xml"
        ./FixMod2Trl.pl -T "$outp.Atag.xml" -O  "$outp.Event.xml"

        echo "";
done    
