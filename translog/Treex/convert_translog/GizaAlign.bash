#!/bin/bash

rm -r  data/Giza
mkdir -p  data/Giza
for file in data/*/Translog-II/*.xml
do
        lang1=`grep Languages $file | grep "=.$1"`
        lang2=`grep Languages $file | grep "=.$2"`

        if [ "$lang1" != "" ] &&  [ "$lang2" != "" ]; then
          sdir=`expr "$file" : 'data/\(.*\)/Translog-II'`
          root=${file%.xml}
          atag=${root/Translog-II/Alignment}
          outp=${root/$sdir\/Translog-II\//Giza\/${sdir}_}
          echo "$atag || $outp || `grep Languages $file`"
          echo "$atag || $outp || `grep Languages $file`" >> "data/Giza/$1-$2.sent"
          ./ExtractTokens.pl -A $atag -O $outp
        fi

done

./GizaAlign.pl -d data/Giza 

