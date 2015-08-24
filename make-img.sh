#!/bin/bash

cat *.wiki | tr ' ' '\n'  \
	| grep http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/ \
	| sed -e 's/http:\/\/copenhagen-dependency-treebank.googlecode.com\/svn\/trunk\/figs\///g' \
	> /tmp/figures.list
figs=`pwd`
cd /home/mtk/html/treebank/figs ; cp -v `cat /tmp/figures.list` $figs/../trunk/figs/ 
cd /home/mtk/html/treebank/figs ; cp -v `cat /tmp/figures.list | sed -e 's/.png$/.tag/g'` $figs/../trunk/figs/ 2>/dev/null
cd /home/mtk/html/treebank/figs ; cp -v `cat /tmp/figures.list | sed -e 's/.png$/.psm/g'` $figs/../trunk/figs/ 2>/dev/null

