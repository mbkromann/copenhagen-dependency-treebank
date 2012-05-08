#!/bin/bash

mkdir -p  data/Giza
for file in data/*/Translog-II/*.xml
do
        lang1=`grep Languages $file | grep "=.$1"`
        lang2=`grep Languages $file | grep "=.$2"`

        if [ "$lang1" != "" ] &&  [ "$lang2" != "" ]; then
          echo "$file `grep Languages $file`" >> "data/Giza/$1-$2.sent"
          sdir=`expr "$file" : 'data/\(.*\)/Translog-II'`
          root=${file%.xml}
          atag=${root/Translog-II/Alignment}
          outp=${root/$sdir\/Translog-II\//Giza\/${sdir}_}
#echo "$file $atag $sdir $outp"
          ./ExtractTokens.pl -A $atag -O $outp
        fi

done

