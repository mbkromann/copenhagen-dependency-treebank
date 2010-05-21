	
all: clean cdt-files figures cdt-manual.pdf

quick: cdt-files cdt-manual.pdf

cdt-manual.pdf: DUMMY
	cp cdt-manual.tex build
	cd build; xelatex cdt-manual ; makeindex cdt-manual ; xelatex cdt-manual ; makeindex cdt-manual ; (xelatex cdt-manual 2>&1 && cp build/cdt-manual.pdf ..) | tee /tmp/cdtmanual.log
	echo "\n\nWarnings:\n"
	@grep Warning /tmp/cdtmanual.log 
	echo "\n"
	
cdt-files: 
	svn update
	mkdir -p build
	rm -f build/build
	cd build ; ln -s . build
	rm -rf build/*.tex build/*.dtag
	dtag -e 'script ~/cdt/tools/scripts/makeconfusion.dtag' -e 'quit'
	./disp2scripts.pl cdt-disposition.txt build/cdt-rels
	dtag -e 'script build/cdt-rels.dtag' -e 'quit'

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
