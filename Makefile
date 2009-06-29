export LANG=C

none: 

da-it.alex: 
	 tools/giza2alex da it
	 cp tmp/da-it.alex da-it/da-it.alex

da-es.alex: 
	 tools/giza2alex da es
	 cp tmp/da-es.alex da-es/da-es.alex

todo.it: 
	ls it/*-auto.tag it/*-tagged.tag | sed -e 's/it-auto.tag//g' -e 's/it-tagged.tag//g' \
		| xargs -I FILE echo -e da-FILEda-it-auto.atag FILEit-auto.tag \
		| ./tools/assign-tasks iørn+morten+lisa morten lisa morten lisa morten lisa morten lisa

todo.es: 
	ls es/*-auto.tag es/*-tagged.tag | sed -e 's/es-auto.tag//g' -e 's/es-tagged.tag//g' \
		| xargs -I FILE echo -e da-FILEda-es-auto.atag FILEes-auto.tag \
		| ./tools/assign-tasks henrik+lotte+søren+jonas lotte søren jonas lotte søren jonas lotte søren jonas lotte søren jonas

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

