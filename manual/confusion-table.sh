#!/bin/bash

name=$1
tmp=/tmp/confusion-table.out.$$

echo "\\section{Confusion table: $name}" > $tmp
echo "\\begin{longtable}{lllp{80mm}}" >> $tmp
echo "\\textbf{R} & \\textbf{A} & \\textbf{N} & \\textbf{Confusion list} \\\\ \\hline" >> $tmp
sed -e 's/\.[0-9]//g' -e 's/\&/\\\&/g' \
    | perl -pe 's/^(([^\t]*)\t.*?\t([0-9]*)%=\2\b)/\3\\%\t\1/g' \
    | sed -e 's/^\([^0-9]\)/0\\%\t\1/g' \
	| sort -nr | sed \
		-e 's/^\([0-9\\%]*\)\t\([^\t]*\)\t\([0-9]*\)/\\rel{\2} \& \1 \& \3 \& \\small/g'\
		-e 's/\t\([0-9]*\)%=\([^\t]*\)/ \\confuse{\1}{\\rel{\2}}/g' \
		-e 's/$/ \\\\/g' >> $tmp

total=`cat $tmp | grep '\\%' | sed -e 's/\\%//g' | awk -F'&' '{ CONVFMT = "%3d" ; sum=sum + $3 ; wsum = wsum + $2 * $3 / 100; print "\\\\hline TOTAL & " 100 * wsum / sum "\\\\% & " sum " & \\\\\\\\"}' | tail -1`

echo $total >> $tmp
echo "\\end{longtable}" >> $tmp
cat $tmp
rm $tmp
