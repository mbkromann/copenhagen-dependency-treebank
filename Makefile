export LANG=C

none:  

missing: 
	svn status | grep -v logs | grep -v '/\.' | egrep -v '(png|eps|ps|pdf)' | grep -v 'confusion/relations-' | grep -v 'manual/script.dtag' | grep -v 'manual/build' | egrep -v '(treebank.dk|docs/relations-cdt)'


webmap:
	if [ ! -f treebank.dk/.ncftp.login ] ; then \
		echo "ERROR: Cannot create webmap without login info in treebank.dk/.ncftp.login"; \
		exit 1; \
	fi
	rm -f tmp/webmap.tag
	for lang in `echo da de en it es` ; do \
		cat `ls $$lang/*.tag | grep -v auto | grep -v tagged` | sed -e "s/<W/<W _lang=\"$$lang\"/g" >> tmp/webmap.tag ; \
	done
	dtag -e 'load tmp/webmap.tag' -e 'webmap' -e 'quit'
	cd treebank.dk/map; cp */MapDep___.html 000/
	make webmap.pngs
	make webmap.upload

webmap.upload:
	cp treebank-index.html treebank.dk/map/index.html
	cd treebank.dk ; cat .upload | ncftp
	#cd treebank.dk ; cat .upload | ncftpput -f .ncftp.login -R public_html .


webmap.clear: 
	find treebank.dk/map -type f | grep -v index.html | xargs rm -f

webmap.pngs:
	cd treebank.dk/map ; for f in `ls */*.tag | sed -e 's/.tag//'` ; do \
		if [ ! -f $$f.png ] ; then \
			dtag -u -q -e "layout -vars /stream:.*/|cat|msd|lexeme|gloss|id" -e "load $$f.tag" -e "print $$f.ps" -e "exit" ; \
            (echo "%!PS-Adobe-2.0" ; cat $$f.ps ) | ps2eps -f -l > $$f.eps ; \
            pstoimg -antialias -scale 1.6 $$f.eps -out $$f.png ; \
            rm $$f.ps $$f.eps ; \
        fi ; \
	done
	make webmap.pngs.missing

webmap.pngs.missing:
	( for f in `cd treebank.dk/map ; ls */ex*.tag | sed -e 's/.tag$$//g'` ; do \
		if [ ! -f treebank.dk/map/$$f.png ] ; then echo $$f ; fi ; \
	done ) | tee treebank.dk/map/missing

da-it.alex: 
	 tools/giza2alex da it
	 cp tmp/da-it.alex da-it/da-it.alex

da-es.alex: 
	 tools/giza2alex da es
	 cp tmp/da-es.alex da-es/da-es.alex

todo.da: 
	ls it/*-auto.tag it/*-tagged.tag | sed -e 's/it-auto.tag//g' -e 's/it-tagged.tag//g' -e 's/it/da/g' \
		| xargs -I FILE echo -e FILEda-disc.tag \
		| ./tools/assign-tasks iorn+morten+lotte morten lotte morten lotte morten lotte 

todo.de: 
	ls de/*-auto.tag de/*-tagged.tag | sed -e 's/de-auto.tag//g' -e 's/de-tagged.tag//g' \
		| xargs -I FILE echo -e da-FILEda-de-auto.atag FILEde-tagged.tag \
		| ./tools/assign-tasks per+morten morten morten morten morten morten morten morten morten 

todo.it: 
	ls it/*-auto.tag it/*-tagged.tag | sed -e 's/it-auto.tag//g' -e 's/it-tagged.tag//g' \
		| xargs -I FILE echo -e da-FILEda-it-auto.atag FILEit-auto.tag \
		| ./tools/assign-tasks iorn+morten+lisa morten lisa morten lisa morten lisa morten lisa
	ls it/*-auto.tag it/*-tagged.tag | sed -e 's/it-auto.tag//g' -e 's/it-tagged.tag//g' \
		| xargs -I FILE echo -e FILEit-disc.tag \
		| ./tools/assign-tasks iorn+morten morten morten morten morten

todo.es: 
	ls es/*-auto.tag es/*-tagged.tag | sed -e 's/es-auto.tag//g' -e 's/es-tagged.tag//g' \
		| xargs -I FILE echo -e da-FILEda-es-auto.atag \
		| ./tools/assign-tasks soren+jonas soren jonas soren jonas soren jonas soren jonas
	ls es/*-auto.tag es/*-tagged.tag | sed -e 's/es-auto.tag//g' -e 's/es-tagged.tag//g' \
		| xargs -I FILE echo -e FILEes-auto.tag FILEes-disc.tag\
		| ./tools/assign-tasks lotte

words:
	for lang in `echo da it es en` ; do cat $$lang/*.txt  | sed -e 's/ /\n/g' | sed -e 's/[       ]//g' | sort | uniq > tmp/words.$$lang; done

all.tag: 
	echo > all.tag	
	for l in `echo da en es it` ; do cat $$l/*.tag | sed -e "s/<W/<W _lang=\"$$l\"/g" >> all.tag ; done

wikidoc: all.tag
	dtag -e 'load all.tag' -e 'perl $$G->wikidoc()' -e 'quit'
	find treebank.dk -name '*.tag' | sed -e 's/.tag/.png/g' | xargs -n 100 -P 4 xmake
	
da-es.texts:
	tools/partexts da es

da-it.texts:
	tools/partexts da it

da-es.autoalign:
	tools/autoalign da es	

da-it.autoalign:
	tools/autoalign da it	

partexts:
	 tools/partexts da es
	 tools/partexts da it
	 tools/partexts da en


examples: .DUMMY
	rm -r examples
	mkdir -p examples
	tmp="/tmp/pdfs.$$$$" ; \
	props="/tmp/svnprops.$$$$" ; \
	for id in `head -20 src/mini1.ids` ; do \
		for dir in `echo da de en es it da-de da-en da-es da-it` ; do \
			files=`ls $$dir/$$id*tag | grep -v auto | grep -v tagged` ; \
			nfiles=`echo $$files | wc -w` ; \
			svnprops=`(svn propget syntax $$files ; svn propget alignment $$files) > $$props` ; \
			if [ $$nfiles -gt 1 ] ; then \
				rm -f $$tmp ; \
				cat $$props | grep final | grep -v outdated > $$tmp ; \
				cat $$props | grep discussed >> $$tmp ; \
				cat $$props | grep first >> $$tmp ; \
				cat $$props | grep outdated-final >> $$tmp ; \
				file=`cat $$tmp | head -1 | awk '{ print $$1}'` ; \
				rm -f $$tmp ; \
			else \
				echo "=== FILE: $$files ===" ; \
				file="$$files"; \
			fi ; \
			pdf=`echo $$file | sed -e 's/\.atag/.pdf/g' -e 's/\.tag/.pdf/g'`; \
			if [ ! -z "$$pdf" ] ; then echo ; echo "=== $$file : $$pdf ===" ; make -f Makefile $$pdf ; mv -f $$pdf examples ; cp $$file examples ; fi ; \
		done ; \
	done
	zip docs/cdt-examples.zip examples/*
	svn add docs/cdt-examples.zip

.DUMMY:


%.ps: %.tag
	dtag -u -q -e "layout -vars /stream:.*/|cat|msd|lexeme|gloss" -e "load $*.tag" -e "print $*.ps" -e "exit"

%.ps: %.atag
	dtag -u -q -e "load $*.atag" -e "print $*.ps" -e "exit"

%.pdf: %.ps
	ps2pdf $*.ps $*.pdf


