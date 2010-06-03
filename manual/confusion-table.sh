#!/bin/bash

name=$1
echo "\\section{Confusion table: $name}"
echo "\\begin{tabular}{lllp{80mm}}"
echo "\\textbf{R} & \\textbf{A} & \\textbf{N} & \\textbf{Confusion list} \\\\ \\hline"
sed -e 's/^\(\([^\t]*\)\t.*\t\([0-9]*\)%=\2\)/\3\\%\t\1/g' \
		-e 's/^\([^0-9]\)/0\\%\t\1/g' \
	| sort -nr | sed \
		-e 's/^\([0-9\\%]*\)\t\([^\t]*\)\t\([0-9]*\)/\\rel{\2} \& \1 \& \3 \& \\small/g'\
		-e 's/\t\([0-9]*\)%=\([^\t]*\)/ \\confuse{\1}{\\rel{\2}}/g' \
		-e 's/$/ \\\\/g'
echo "\\end{tabular}"
