%.tag: %.txt 
	~/svn/cdt/trunk/tools/de2tag $*.txt

all:
	make `ls *.txt | sed -e 's/.txt/.tag/g'`
