dtag=~/cdt/dtag/dtag.pl

all: clean cdt-files figures cdt-manual.pdf

quick: cdt-files cdt-manual.pdf

cdt-manual.pdf: DUMMY
	cp cdt-manual.tex build
	cd build; xelatex cdt-manual ; makeindex cdt-manual ; xelatex cdt-manual ; makeindex cdt-manual ; (xelatex cdt-manual 2>&1 && cp build/cdt-manual.pdf ..) | tee /tmp/cdtmanual.log
	@echo "\n\nWarnings:\n"
	@grep Warning /tmp/cdtmanual.log  || echo "none\n\nSUCCESSFULLY GENERATED cdt-manual.pdf"
	
cdt-files: cdt-compile confusion status

cdt-compile:
	svn update ~/cdt/manual ~/cdt/confusion ~/cdt/docs
	mkdir -p build
	rm -f build/build
	cd build ; ln -s . build
	rm -rf build/*.tex build/*.dtag
	rm -f ~/cdt/docs/relations-cdt.csv
	${dtag} -e 'script ~/cdt/tools/scripts/makeconfusion.dtag' -e 'quit'
	./disp2scripts.pl cdt-disposition.txt build/cdt-rels
	./disp2scripts.pl cdt-disposition-topics.txt build/cdt-topics
	${dtag} -e 'script build/cdt-rels.dtag' -e 'quit'
	${dtag} -e 'script build/cdt-topics.dtag' -e 'quit'

confusion:
	for f in `cd ~/cdt/confusion ; ls confusion-*` ; do \
		g=`echo $$f | sed -e 's/^confusion-//g' -e 's/.csv$$//g'` ; \
		cat ~/cdt/confusion/$$f | ./confusion-table.pl $$g > build/$$f.tex ; \
	done

status:
	~/cdt/tools/dtag-statusall da en de es it da-en da-de da-es da-it | grep -v 'TEXT COUNTS' | grep -v 'dims: ' \
		| sed -e 's/=== ALL ===/\\section{All texts}\n\\begin{verbatim}\n/g' -e 's/=== \(.*\) ===/\\end{verbatim}\n\\section{\1 texts}\n\\begin{verbatim}\n/g' | egrep -v '^$$' > build/statusall.tex
	echo '\\end{verbatim}' >> build/statusall.tex

figures: 
	ls build/*.dtag | grep -v script | sed -e 's/^\(.*\).dtag$$/script \1.dtag\nprint \1.ps/g' > build/script.dtag
	${dtag} -e 'cdtmanualsetup' -e 'script build/script.dtag' -e 'quit!'
	for f in `ls build/*.dtag | grep -v script | sed -e 's/.dtag$$//g'` ; do \
		echo "===" $$f "===" ; \
		(echo "%!PS-Adobe-2.0" ; cat $$f.ps) | ps2eps -f -l > $$f.eps ; \
		epstopdf $$f.eps -o $$f.pdf ; \
	done

clean:
	rm -rf build/*

DUMMY: 
