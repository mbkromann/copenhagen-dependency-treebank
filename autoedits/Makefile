
all:
	make `ls *.dtag *.tab | sed -e 's/\.dtag$$/.log/'`

%.log: %.dtag
	dtag -e "viewer" -e "script $*.dtag" -e "exit" 2>&1 | tee $*.log
	svn add --force $*.dtag $*.log
	dtag -e "commit Autoedit with script $*" -e "exit"

%.log: %.tab
	cat $*.tab | ./tab2sed > $*.sed
	svn add --force $*.dtag $*.log
	dtag -e "commit Autoedit with script $*" -e "exit"

