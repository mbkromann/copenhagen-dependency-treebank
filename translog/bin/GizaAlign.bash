#!/bin/bash

if [ "$1" == "" ] || [ "$2" == "" ]; then
  echo "Source and target languages required"
  exit
fi
 
#./CopyExpData.bash

rm -r  data/Giza
mkdir -p  data/Giza
### Sentence Segmentation
### get language pair from Translog-II files
### get tokens from atag files
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
          ./Atag2Sentences.pl -A $atag -O $outp
        fi

done

./GizaAlign.pl -d data/Giza  

cat data/Giza/$1-$2.sent | ./Giza2Atag.pl 

