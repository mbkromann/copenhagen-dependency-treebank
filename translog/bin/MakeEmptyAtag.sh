#!/bin/bash

if [ "$1" == "" ]; then
  echo "$0 Path "
  exit
fi


for file in $1/Alignment/*.src
do
	atag=${file/.src}
	root=${atag/$1\/Alignment\/}
        if [ -f $atag.atag ] 
        then
		echo skipping $atag.atag 
		continue
	fi

        echo "Create $atag.atag"
        echo "<DTAGalign>" > $atag.atag
        echo "    <alignFile key=\"a\" href=\"$root.src\" sign=\"_input\"/>" >> $atag.atag
        echo "    <alignFile key=\"b\" href=\"$root.tgt\" sign=\"_input\"/>" >> $atag.atag
        echo "</DTAGalign>" >> $atag.atag
done


