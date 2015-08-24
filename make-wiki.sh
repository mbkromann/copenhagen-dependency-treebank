#!/bin/bash

export LANG=C
for f in `ls [A-Z]* | grep -v '\.'` ; do
	name=`echo $f | sed -e 's/\([A-Z]\)/ \1/g'`
	echo -e "== $name ==\n" > $f.wiki
	iconv -f ISO-8859-1 -t utf8 $f > $f.tmp
	echo $f
	html2wiki --dialect MoinMoin --base-uri http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/ --wiki-uri http://code.google.com/p/copenhagen-dependency-treebank/wiki/ $f.tmp >> $f.wiki
	rm $f.tmp
done
