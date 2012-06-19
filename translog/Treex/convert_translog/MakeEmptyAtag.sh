#!/bin/bash

for file in Alignment/*.src
do
	atag=${file/.src}
	root=${atag/Alignment\/}
        if [ -f $atag.atag ] 
        then
		echo $atag.atag exists!
		continue
	fi

        echo "Create $atag.atag"
        echo "<DTAGalign>" > $atag.atag
        echo "    <alignFile key=\"a\" href=\"$root.src\" sign=\"_input\"/>" >> $atag.atag
        echo "    <alignFile key=\"b\" href=\"$root.tgt\" sign=\"_input\"/>" >> $atag.atag
        echo "</DTAGalign>" >> $atag.atag
done


