SRCDIR := $(shell pwd)
BINDIR = ${SRCDIR}/bin
RUNDIR = ${SRCDIR}/run
SRCDIRS = Interpreter Lexicon Graph Parse Learner LexInput Alignment ALexicon
export LC_ALL=C

# Compile the sources into Perl code
code: serverdirs
	echo SRCDIR ${SRCDIR}
	echo BINDIR ${BINDIR}
	export LC_ALL=POSIX
	cd PostScript ; make
	mkdir -p ${RUNDIR}/DTAG
	RELEASE=`cat .release` ; DATE=`date +"%Y-%m-%d %k:%M:%S"`; echo $$RELEASE; (head -1 dtag; cat LICENSE dtag) | sed -e "s/RELEASE = ''/RELEASE = '$$RELEASE ($$DATE)'/" > ${RUNDIR}/dtag
	chmod 755 ${RUNDIR}/dtag
	cp dtagrc* ${RUNDIR}/
	cp dtag-cgi ${RUNDIR}
	cp PostScript/arcs.header PostScript/arcs.trailer ${RUNDIR}
	cp PostScript/align.header PostScript/align.trailer ${RUNDIR}
	cp PostScript/box.header PostScript/box.trailer ${RUNDIR}
	cp LICENSE* ${RUNDIR}
	export LICENSE="`pwd`/LICENSE"; for dir in `echo ${SRCDIRS}` ; do \
		(cd $$dir; export DTAGBINDIR=${BINDIR}; ${BINDIR}/makepm $$dir/) > ${RUNDIR}/DTAG/$$dir.pm ; \
	done

serverdirs:
	mkdir -p run/server run/server/queries run/server/matches run/server/data
	touch run/server/lookup run/server/qid
	chmod -R -f a+rw run/server/ || exit  0
	
# Process HTML files in documentation
doc: code html/*.mhtml
	${BINDIR}/makehtml
	for f in `echo ${SRCDIRS}` ; do \
		pod2html --title="DTAG::$$f" run/DTAG/$$f.pm > html/pod/$$f.html ; \
		pod2man run/DTAG/$$f.pm > man/$$f.man ; \
	done


# Run all regression tests
test: code
	@ failed=""; pass=0; tests=0; (for testdir in `find . \( -name '*cvs' -o -name 'releases' -o -name '*cvs' \) -prune -o -name test -type d -print | sort` ; do \
		for test in `find $$testdir -maxdepth 1 -type f \
				\( -name '.*' -o \( \( -name '*.dtag' -o -name '*.pl' \) -a -print \) \) | sort` ; do \
			tests=$$(($$tests+1)); \
			${BINDIR}/maketest $$test && pass=$$(($$pass+1)) || failed="$$failed $$test"; \
		done ; \
	done; echo "Passed $$pass and failed $$(($$tests-$$pass)) out of $$tests tests." ; echo "Failed tests: $$failed" ) | tee test.log

# Compute the number of lines in the code
size: code
	wc run/DTAG/*.pm run/dtag PostScript/align.ps PostScript/arcs.ps

# Find all files that perhaps should be included in the CVS repository
missing: 
	@ cvs log 2>/dev/null \
		| egrep '^\?' \
		| sed -e 's/^\? //' \
		| egrep -v '^(lexicon|releases|run|tagging|.*cvs|trash|MAKEFILE|test.log).*' \
		| egrep -v '*\.(png|html|db|lex|out)' \
		| tee missing.log

	
# Create a new release of DTAG, tagging the sources with an
# auto-generated release tag
release:
	major=`cat .release | sed -e 's/\(.*\)\.[0-9]*/\1/g'`; \
	minor=`cat .release | sed -e 's/.*\.\([0-9]*\)/\1/g'` ; \
	tag=`cat .release | sed -e 's/\./_/g'` ; \
	mv tagging tagging~ ; \
	mv tagging~ tagging ; \
	echo "RELEASED DTAG VERSION dtag-$$tag" ; \
	echo $$major.$$(($$minor+1)) > .release
	#svn tag dtag-$$tag . ; \

# Create a new release of the Danish Dependency Treebank
release-ddt:
	cd tagging/danish ; make release

# Download the sources into directory "cvs" using anonymous CVS
cvs.download: 
	rm -rf cvs
	mkdir -p cvs
	cd cvs ; cvs -z3 -d:pserver:anonymous@disgram.cvs.sf.net:/cvsroot/disgram co -P .

# Download the sources into directory "cvs" using developer CVS
mycvs.download: 
	rm -rf mycvs
	mkdir -p mycvs
	cd mycvs ; cvs -z3 -d:ext:mtkromann@disgram.cvs.sf.net:/cvsroot/disgram co -P .

# Watch latest ehpm file
watch: 
	while [ 0 = 0 ] ; do osum=$$sum; file=`cd ehpm ; ls --sort=time *.eps | grep -v current.eps` ; sum=`sum ehpm/$$file` ; if [ "$$osum" != "$$sum" ] ; then (gv ehpm/$$file &); fi; sleep 5; done
watch2: 
	while [ 0 = 0 ] ; do osum=$$sum; file=`cd ehpm ; ls --sort=time *.eps | grep -v current.eps | head -1` ; sum=`sum ehpm/$$file` ; if [ "$$osum" != "$$sum" ] ; then cp ehpm/$$file ehpm/current.eps; fi; sleep 5; done

testlearn: 
	dtag -e 'perl DTAG::Learner->test()' | tee -a `date +'output-%Y-%m-%d.log'`

dtag.tar.gz: 
	make
	tar cvzf dtag.tar.gz /opt/dtag/*
	md5sum dtag.tar.gz > dtag.tar.gz.md5.txt
	chmod 755 dtag.tar.gz*

cdt: code
	echo `awk -F. '{ print $$1"."$$2"."$$3+1 }' .release` > .newrelease
	mv .newrelease .release
	cd run ; tar cf - . | tar xvf - -C /home/matthias/research/svn/cdt/trunk/dtag/
	cd /home/matthias/svn/cdt/trunk/dtag ; mv dtag dtag.pl
	cd /home/matthias/research/svn/cdt/trunk/dtag ; svn add .
	cd /home/matthias/research/svn/cdt/trunk/dtag ; svng -m 'Automatic_DTAG_update' commit


