
all:
	make `ls *.dtag | sed -e 's/\.dtag$$/.log/'`

%.log:
	dtag -e "viewer" -e "script $*.dtag" -e "exit" 2>&1 | tee $*.log
	svn add --force $*.dtag $*.log
	dtag -e "commit Autoedit with script $*.dtag" -e "exit"

%.sed: %.tab
	cat $*.tab | ./tab2sed > $*.sed
