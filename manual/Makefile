	
all: clean cdt-files figures cdt-manual.pdf

quick: cdt-files cdt-manual.pdf

cdt-manual.pdf: DUMMY
	cd build; xelatex cdt-manual ; makeindex cdt-manual ; xelatex cdt-manual ; makeindex cdt-manual ; (xelatex cdt-manual 2>&1 && cp build/cdt-manual.pdf ..) | tee /tmp/cdtmanual.log
	echo "\n\nLaTeX warnings:\n\n"
	@grep Warning /tmp/cdtmanual.log 

	
cdt-files: 
	svn update
	mkdir -p build
	rm -f build/build
	cd build ; ln -s . build
	rm -rf build/*.tex build/*.dtag
	./disp2scripts.pl cdt-disposition.txt build/cdt-rels
	dtag -e 'script build/cdt-rels.dtag' -e 'quit'
	cp cdt-manual.tex build

figures: 
	ls build/*.dtag | grep -v script | sed -e 's/^\(.*\).dtag$$/script \1.dtag\nprint \1.ps/g' > build/script.dtag
	dtag -e 'cdtmanualsetup' -e 'script build/script.dtag' -e 'quit!'
	for f in `ls build/*.dtag | grep -v script | sed -e 's/.dtag$$//g'` ; do \
		echo "===" $$f "===" ; \
		(echo "%!PS-Adobe-2.0" ; cat $$f.ps) | ps2eps -f -l > $$f.eps ; \
		epstopdf $$f.eps -o $$f.pdf ; \
	done

clean:
	rm -rf build/*

DUMMY: 
