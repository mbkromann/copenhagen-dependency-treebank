all: arcs.header arcs.trailer align.header align.trailer tree.header tree.trailer

%.info: %.ps
	./chunk $*.ps '%!' '%%BeginPrologue' > $*.info
	
%.header: %.ps %.info
	./chunk $*.ps '%%BeginPrologue' '%%EndPrologue' > .$*.header
	cp $*.info $*.header
	./reduce .$*.header > .$*.header2
	vim -s .reduce.vim .$*.header2
	cat .$*.header2 >> $*.header
	echo "\n%% 2. Graph specification\n" >> $*.header

%.trailer: %.ps
	./chunk $*.ps '%%BeginTrailer' '%%EndTrailer' > .$*.trailer
	echo "%% 3. Trailer\n" > $*.trailer
	./reduce .$*.trailer >> $*.trailer

arcs.template: arcs.header arcs.trailer
	cat arcs.header > arcs.template
	echo "% Number of labels L, nodes W, and edges E in graph" >> arcs.template
	echo '% syntax: $$labels $$words $$edges setup\n' >> arcs.template
	echo "\t% L W E setup\n" >> arcs.template
	echo "% Layout formats (optional): list of PostScript code objects" >> arcs.template
	echo "% that change the PostScript graphics state (font, color, dash)." >> arcs.template
	echo "% The formats are numbered from 1 to N, with format 0" >> arcs.template
	echo "% interpreted as meaning no format.\n" >> arcs.template
	echo "\t% /formats [" >> arcs.template
	echo '\t% \t {$$postscript1}' >> arcs.template
	echo '\t% \t ...' >> arcs.template
	echo  '\t% \t {$$postscriptF}' >> arcs.template
	echo  "\t% ] def\n" >> arcs.template
	echo  "% Words in dependency graph" >> arcs.template
	echo  '% syntax: $$label1 [$$format1] ... $$labelW [$$formatW] word\n' >> arcs.template
	echo  "\t% (label1.1) (label1.2) ... (label1.L) word" >> arcs.template
	echo  "\t% ..." >> arcs.template
	echo  "\t% (labelW.1) (labelW.2) ... (labelW.L) word\n" >> arcs.template
	echo  "% Edges in dependency graph (top/bottom edges)" >> arcs.template
	echo  '% syntax: $$innode $$outnode ($$label) [$$labelformat [$$arcformat]] edget' >> arcs.template
	echo  '%         $$innode $$outnode ($$label) [$$labelformat [$$arcformat]] edgeb\n' >> arcs.template
	echo  "\t% in1 out1 (label1) edget    OR:   in1 out1 (label1) edgeb" \
		>> arcs.template
	echo  "\t% ..." \
		>> arcs.template
	echo  "\t% inE outE (labelE) edget    OR:   inE outE (labelE) edgeb\n" \
		>> arcs.template
	cat arcs.trailer >> arcs.template

tree.info: tree.ps
	./chunk tree.ps '%!' '%%BeginPrologue' > tree.info
	
tree.header: tree.ps tree.info
	./chunk tree.ps '%%BeginPrologue' '%%EndPrologue' > .tree.header
	cp tree.info tree.header
	./reduce .tree.header >> tree.header

tree.trailer: tree.ps
	./chunk tree.ps '%%BeginTrailer' '%%EndTrailer' > .tree.trailer
	./reduce .tree.trailer > tree.trailer
