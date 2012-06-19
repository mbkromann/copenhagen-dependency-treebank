#!/bin/bash


mkdir -p data/Treex
#for file in data/{Annette_translate,EN-DA,ED12,EN-DE_TPR-PE,EN-ES,EN-HI,EN-PT_TPR-PE,EN-ZH,L1L2}/Events/*Event.xml
for file in data/{Annette_translate,EN-DA,ED12,EN-ES}/Events/*Event.xml
do
        treex=${file%.xml}
        treex=${root/Events/Treex}

        echo "./Trl2Treex.pl  -T $file -O $treex"
        ./Trl2Treex.pl -T $file -O $treex
        echo "";
done    
