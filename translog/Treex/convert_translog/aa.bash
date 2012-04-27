#!/bin/bash

mkdir -p data/FixMod

for file in data/Merged/*.xml
do
        maped=${file/Merged/FixMod}
	echo "./FixMod2Trl.pl -T $file -O $maped.FixMod"
	./FixMod2Trl.pl -T $file -O "$maped.FixMod"
	echo "./ComputeUnits.pl -T $maped.FixMod > $maped"
	./ComputeUnits.pl -T "$maped.FixMod" > $maped
done
