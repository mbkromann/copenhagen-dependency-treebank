
cdt-manual.pdf: cdt-files
	cp cdt-manual.tex build
	cd build; xelatex cdt-manual ; makeindex cdt-manual ; xelatex cdt-manual ; makeindex cdt-manual ; xelatex cdt-manual && cp build/cdt-manual.pdf ..

all: figures cdt-manual.pdf

clean:
	rm -rf build/*

cdt-files: 
	svn update
	mkdir -p build
	rm -f build/build
	cd build ; ln -s . build
	rm -rf build/*.tex build/*.dtag
	./disp2scripts.pl cdt-disposition.txt build/cdt-rels
	dtag -e 'script build/cdt-rels.dtag' -e 'quit'

figures: build/*.dtag
	ls build/*.dtag | sed -e 's/^\(.*\).dtag$$/script \1.dtag\nprint \1.ps/g' > build/script.dtag
	dtag -e 'nonumbernodes' -e 'script build/script.dtag' -e 'quit!'
	for f in `ls build/*.dtag | sed -e 's/.dtag$$//g'` ; do \
		(echo "%!PS-Adobe-2.0" ; cat $$f.ps) | ps2eps -f -l > $$f.eps ; \
		epstopdf $$f.eps -o $$f.pdf ; \
	done

DUMMY: 
