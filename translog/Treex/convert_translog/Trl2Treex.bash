#!/bin/bash

mkdir -p data/Treex

for file in data/FixMod/*.xml
do
        treex=${file%.xml}
        treex=${treex/Merged/Treex}
	echo "./Trl2Treex.pl -T $file -O $treex"
	./Trl2Treex.pl -T $file -O $treex
done
