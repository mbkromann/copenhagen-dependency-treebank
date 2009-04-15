train: cdt-it.train cdt-es.train
	# cdt-it.mco cdt-it-train.mco cdt-es.mco cdt-es-train.mco

test: test-it test-es

test-it: 
	java -jar malt/malt.jar -c cdt-it-train -i cdt-it-test.conll -o parse-cdt-it-test.conll -m parse 
	make cdt-it-test.conll.tag parse-cdt-it-test.conll.tag
	echo dtag -e 'load parse-cdt-it-test.conll.tag' -e 'diff cdt-it-test.conll.tag'

test-es: 
	java -jar malt/malt.jar -c cdt-es-train -i cdt-es-test.conll -o parse-cdt-es-test.conll -m parse 
	make cdt-es-test.conll.tag parse-cdt-es-test.conll.tag
	echo dtag -e 'load parse-cdt-es-test.conll.tag' -e 'diff cdt-es-test.conll.tag'

%.train: %.tag
	make $*.conll $*-train.conll $*-test.conll
	make $*.mco $*-train.mco

%: %.tag.train %.conll %.mco parse-%.conll

%.mco: %.conll
	java -jar malt/malt.jar -c $* -i $*.conll -m learn

%.conll.tag: %.conll
	dtag -e "load $*.conll" -e "save $*.conll.tag" -e "quit"

cdt-%.tag: /home/matthias/svn/cdt/trunk/%/*.tag
	cat `ls /home/matthias/svn/cdt/trunk/$*/*.tag | grep -v 'auto'` > cdt-$*.tag
	cat `ls /home/matthias/svn/cdt/trunk/$*/*.tag | grep -v 'auto' | grep -v '/01'` > cdt-$*-train.tag
	cat `ls /home/matthias/svn/cdt/trunk/$*/*.tag | grep -v 'auto' | grep '/01'` > cdt-$*-test.tag

%.conll: %.tag
	dtag -e "load $*.tag" -e "save $*.conll" -e 'quit'

%.parse.conll:
	java -jar malt/malt.jar -c $* -i $*.conll -o $*.parse.conll -m parse 

%.parse-cdt-it.tag: %.conll
	java -jar malt/malt.jar -c cdt-it-train -i $*.conll -o $*.parse-cdt-it.conll -m parse 
	make $*.parse-cdt-it.conll.tag
	grep -v '</s>' $*.parse-cdt-it.conll.tag > $*.parse-cdt-it.tag
	
