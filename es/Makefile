%.tag: %.txt 
	~/svn/cdt/trunk/tools/es2tag $*.txt

all:
	make `ls *.txt | sed -e 's/.txt/.tag/g'`
