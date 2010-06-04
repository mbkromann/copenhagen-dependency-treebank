export LANG=C

none:  

missing: 
	svn status | grep -v logs | grep -v '/\.' | egrep -v '(png|eps|ps|pdf)' | grep -v 'confusion/relations-' | grep -v 'manual/script.dtag' | grep -v 'manual/build' | egrep -v '(treebank.dk|docs/relations-cdt)'


webmap:
	rm -f tmp/webmap.tag
	for lang in `echo da en it es` ; do \
		cat $$lang/*.tag | sed -e "s/<W/<W _lang=\"$$lang\"/g" >> tmp/webmap.tag ; \
	done
	dtag -e 'load tmp/webmap.tag' -e 'webmap' -e 'quit'
	cd treebank.dk/maps; cp MapDep___.html index.html
	make webmap.pngs

webmap.clear: 
	find treebank.dk/map -type f | grep -v index.html | xargs rm -f

webmap.pngs:
	cd treebank.dk/map ; for f in `ls *.tag | sed -e 's/.tag//'` ; do \
		if [ ! -f $$f.png ] ; then \
			dtag -u -q -e "layout -vars /stream:.*/|cat|msd|lexeme|gloss|id" -e "load $$f.tag" -e "print $$f.ps" -e "exit" ; \
            (echo "%!PS-Adobe-2.0" ; cat $$f.ps ) | ps2eps -f -l > $$f.eps ; \
            pstoimg -antialias -scale 1.6 $$f.eps -out $$f.png ; \
            rm $$f.ps $$f.eps ; \
        fi ; \
	done
	make webmap.pngs.missing
	cd treebank.dk ; lftp -f .upload

webmap.pngs.missing:
	( for f in `cd treebank.dk/map ; ls ex*.tag | sed -e 's/.tag$$//g'` ; do \
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

