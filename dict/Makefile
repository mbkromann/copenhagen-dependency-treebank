CDT=~/cdt
TOOLS=${CDT}/tools

all: da-abbr-auto.txt da-multiword-tagged-auto.txt

da-stanford-tagger.model: da-stanford-tagger.train
	java -classpath ../lib/stanford-postagger.jar \
		edu.stanford.nlp.tagger.maxent.MaxentTagger \
		-prop da-stanford-tagger.prop \
		-model da-stanford-tagger.model \
		-trainFile da-stanford-tagger.train 

da-stanford-tagger.train:
	cat ${CDT}/da/[0-9][0-9][0-9][0-9]-da.tag ${CDT}/da/tagged/*.tag \
		| ${TOOLS}/tag2pos -mw=da-multiword-tagged.txt > da-stanford-tagger.train

da-stanford-tagger.train.in: da-stanford-tagger.train
	cat da-stanford-tagger.train | ../tools/pos2tok > da-stanford-tagger.train.in

da-stanford-tagger.closed: 
	cat ${CDT}/da/[0-9][0-9][0-9][0-9]-da.tag ${CDT}/da/tagged/*.tag \
		| grep '</W>' | sed -e 's/^.*msd="\([^"]*\)".*$$/\1/g' \
		| sort | uniq | egrep -v '^(A|N|RGU|VA|XF|XR|XX)' \
		> da-stanford-tagger.closed

da-abbr-auto.txt:
	egrep '>[^><]*\.[^><]*<' ../da/*.tag ../da/tagged/*.tag \
		| grep '</W>' \
		| grep -v '>.</W>' \
		| sed -e 's/^.*>\(.*\)<\/W>.*$$/\1/g' \
		| sed -e 's/^.*>\(.*\)<.*$$/\1/g' \
		| egrep -v '^..$$' \
		| egrep -v '^[0-9][0-9.:,-]*$$' \
		| awk '{ print tolower($$1) }' \
		| sort | uniq > da-abbr-auto.txt
	
#da-abbr-tagged-auto.txt: da-abbr.txt
#	( for w in `cat da-abbr.txt` ; do \
#		echo -n "$$w\t" ; \
#		msd=`~/cdt/tools/da-word2msd $${w} | head -1 | awk '{ print $$2 }'`; \
#		if [ -z "$$msd" ] ; then msd="??" ; fi ; \
#		echo "$$w/$$msd "; \
#	done ) > da-abbr-tagged-auto.txt
	
da-multiword.txt: 
	grep '>[^><]*_[^><]*<' ../da/*.tag ../da/tagged/*.tag \
		| sed -e 's/^.*>\([^><]*\)<\/W>/\1/g' \
		| awk '{ print tolower($$1) }' \
		| sort | uniq -c \
		| sort -nr > da-multiword.txt

da-multiword-tagged-auto.txt: da-multiword.txt
	( for mw in `awk '{ print $$2 }' da-multiword.txt` ; do \
		echo -n "$$mw\t" ; \
		for w in `echo $${mw} | sed -e 's/-/ - /g' -e 's/_/ /g'` ; do \
			msd=`~/cdt/tools/da-word2msd $${w} | head -1 | awk '{ print $$2 }'`; \
			if [ -z "$$msd" ] ; then msd="??" ; fi ; \
			echo -n "$$w/$$msd "; \
		done ; \
		echo "" ;\
	done ) > da-multiword-tagged-auto.txt
	

