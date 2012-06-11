#!/bin/bash

#rm -r data/$1
for file in ../../$1/Translog-II/*.xml
do
	sdir=`expr "$file" : '../../\(.*\)/Translog-II'`
        mkdir -p data/${sdir}/Translog-II
        echo "cp  $file data/${sdir}/Translog-II"
        cp -r  $file data/${sdir}/Translog-II/
done

for file in ../../$1/Alignment/*.{src,tgt,atag}
do
	sdir=`expr "$file" : '../../\(.*\)/Alignment'`
        mkdir -p data/${sdir}/Alignment
        echo "cp  $file data/${sdir}/Alignment"
        cp -r  $file data/${sdir}/Alignment/
done

