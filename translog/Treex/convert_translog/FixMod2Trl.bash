#!/bin/bash

mkdir -p data/FixMod

for file in data/Merged/*.xml
do
        maped=${file/Merged/FixMod}
	echo "./FixMod2Trl.pl -T $file -O $maped"
	./FixMod2Trl.pl -T $file -O $maped
done
