export LANG=C

none: 

export LANG=C

none: 

webmap:
	rm -f tmp/webmap.tag
	for lang in `echo da en it es` ; do \
		cat $$lang/*.tag | sed -e "s/<W/<W _lang=\"$$lang\"/g" >> tmp/webmap.tag ; \
	done
	dtag -e 'load tmp/webmap.tag' -e 'webmap' -e 'quit'
	make webmap.pngs

webmap.pngs:
	cd treebank.dk/map ; for f in `ls *.tag | sed -e 's/.tag//'` ; do \
		if [ ! -f $$f.png ] ; then \
			dtag -u -q -e "layout -vars /stream:.*/|cat|msd|lexeme|gloss|id" -e "load $$f.tag" -e "print $$f.ps" -e "exit" ; \
            ps2epsi $$f.ps $$f.eps ; \
            pstoimg -antialias -scale 1.6 $$f.eps -out $$f.png ; \
            rm $$f.ps $$f.eps ; \
        fi ; \
	done
	( for f in `ls treebank.dk/map/ex*.tag | sed -e 's/.tag$//g'` ; do \
		if [ ! -f $f.png ] ; then echo $f ; fi ; \
	done ) > treebank.dk/map/missing
	cat treebank.dk/map/missing
	cd treebank.dk ; lftp -f .upload

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

