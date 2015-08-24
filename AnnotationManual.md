## Annotation Manual ##

## Danish Dependency Treebank ##

### Annotation guide ###

**[Matthias T. Kromann](http://copenhagen-dependency-treebank.googlecode.com/svn/)[[BR](BR.md)][Department of Computational Linguistics](http://www.id.cbs.dk)[[BR](BR.md)][Copenhagen Business School](http://www.cbs.dk)[[BR](BR.md)] (project coordinator, main author)**

**[Line Mikkelsen](http://people.ucsc.edu/~lmikkels)[[BR](BR.md)][Department of Linguistics](http://ling.ucsc.edu)[[BR](BR.md)][University of California, Santa Cruz](http://www.ucsc.edu)[[BR](BR.md)] (research assistant)**

**[Stine Kern Lynge](http://www.id.cbs.dk/~stine)[[BR](BR.md)][Department of Computational Linguistics](http://www.id.cbs.dk)[[BR](BR.md)][Copenhagen Business School](http://www.cbs.dk)[[BR](BR.md)] (research assistant)**

### Purpose ###

This annotation guide describes the principles behind the syntactic analyses of sentences in the Danish Dependency Treebank. The treebank has several purposes:

  * to enable linguists to search for particular syntactic constructions in Danish (eg, topicalized objects, verbs with a particular valency frame, discontinuities, passives, expletives), and categorize the search results according to syntactic criteria;
  * to act as a computational linguistics resource for statistical parsing, grammar development, term extraction, semantic analysis, discourse parsing, etc;
  * to obtain a comprehensive understanding of syntactic constructions in Danish and their frequency;
  * to specify a syntactic analysis of Danish within the dependency-based syntax formalism "[Discontinuous Grammar](http://copenhagen-dependency-treebank.googlecode.com/svn/dg)".

The quality of a treebank depends mostly on the quality of the underlying syntactic analyses. Therefore it is vital that:

  * the analyses must be motivated by a precise, comprehensive and coherent theory of Danish grammar (ie, the grammar must lead to valid predictions about sentence grammaticality in written Danish);
  * the annotation principles must be formulated in a computational grammar of Danish that can be used to check the consistency of the annotation;
  * the analyses must have a semantic functor-argument structure that is compatible with a reasonable compositional semantics for Danish;
  * the treebank analyses must be easy to relate to analyses within the widest possible range of syntactic frameworks (eg, HPSG, LFG, TAG, GB, Dependency Grammar and Functional Grammar).

There is currently no generally accepted standard on how to create a treebank. Some treebanks, like the Penn treebank, are based on phrase structure; other treebanks, like the Prague treebank, are based on dependency structure. In many computational applications (eg, training of statistical parsers), it is important to be able to read off argument and valency structure from the treebank, ie, these applications require a lexical view where the lexical properties of the words can be deduced directly from the treebank analyses. Phrase structure trees do not directly reflect argument or valency structure (eg, in long-distance dependencies, valents can be arbitrarily far from their governors), whereas dependency trees encode argument and valency structure directly, although most phrase-structure based theories assume a level of analysis that roughly corresponds to a dependency graph (D-structure in GB, valency structure in HPSG, f-structure in LFG, the parse tree in TAG). Consequently, Owen Rambow (personal communication) has strongly recommended that treebanks should be based on dependency structure rather than phrase structure, and we intend to follow his recommendation.

Our thoughts on these issues are described in more detail in the following [abstract for the Swedish Treebank Symposium](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/files/stb-2002.pdf) at Växjö University, November 2002.

The treebank is therefore based on Discontinuous Grammar (DG), a computationally oriented syntax formalism created by M.T. Kromann, based on dependency theory. DG combines ideas from many different syntax formalisms: GB, GPSG/HPSG, LFG, TAG, Word Grammar, and classical dependency theory.

### Credits ###

In our analyses of linguistic phenomena in Danish, we try to state references from the linguistic literature if the reference has directly influenced our analysis, or if the phenomenon is controversial and the reference has a particularly insightful analysis of it. However, many analyses in linguistics have been absorbed into linguistic "folklore", where it is no longer possible for non-historians to trace the ideas back to their origin and assign proper credit for them, or mention all the linguists who have discussed the phenomenon in the past. Thus, the absence of a reference by no means implies any originality on our part. Indeed, more often than not, we are heavily indebted to the many linguists before us who have contributed ideas that inform the analyses we present here, even if we are unaware of their origin. We therefore apologize if we have omitted important references, and kindly request you to contact us if you are aware of an important reference that we missed.

Some of our sources deserve special mention. We have been inspired by the work of the dependency grammarians Gerhard Helbig and Richard Hudson, by the great tradition of Danish linguists like Otto Jespersen and Paul Diderichsen, by the great body of highly informed analyses in formal syntactic theories like GB, HPSG, LFG, TAG, and by the many insights from functional theories. We also wish to thank the following linguists, who in both large and small ways helped us with advice, encouragement, and linguistic ideas: Niels Davidsen-Nielsen, Per Anker Jensen, Alex Klinge, Barbara Partee, Geoff Pullum, Owen Rambow, Carl Vikner, Sten Vikner.

More specific references can be found in our list of [references](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/refs.html). The document revision history can be browsed in the following [CVS tree](http://cvs.sf.net/cgi-bin/viewcvs.cgi/disgram/tagging/danish/).

### Colors ###

In the annotation manual, we have used the following color coding to distinguish between different types of text.

**old:** Text on red background is old deprecated stuff which has been marked for deletion by Stine. It may contain a lot of errors and should be ignored when reading the annotation manual.

**question:** Text on orange background is used when an author wants to insert a question into the annotation manual, directed to the other authors of the manual.

**stine:** Text on yellow background indicates additions to the tagging manual created by Stine.

**discussion:** Text on green background indicates that the text presents alternative analyses and theoretical discussions. Note that the analyses presented here are usually ''not'' recommended by the annotation manual.

**example:** Text on cyan background is used in some example boxes.

### Links ###

For a general introduction to dependency theory, we recommend Richard Hudson's:

  * [Encyclopedia of Word Grammar](http://www.phon.ucl.ac.uk/home/dick/encyclopedia/encframe.htm)

The list below provides links to all treebanks and associated annotation manuals that are known to us:

  * [Alpino Dependency Treebank](http://www.id.cbs.dk/~mtk/files/011001-entcs.pdf)
  * [Corpus Gesproken Nederlands](http://lands.let.kun.nl/cgn/ehome.htm) ([tagging manual](http://lands.let.kun.nl/cgn/protocs/syn_prot.pdf))
  * [English Dependency Treebank](http://www.cis.upenn.edu/~creswell/dependency/)
  * [HPSG-based Syntactic Treebank of Bulgarian (BulTreeBank)](http://www.bultreebank.org/)
  * [HPSG treebank for Polish](http://dach.ipipan.waw.pl/CRIT2/)
  * [LinGO Redwoods HPSG treebank](http://lingo.stanford.edu/redwoods/)
  * [METU treebank for Turkish](http://www.ii.metu.edu.tr/~corpus/treebank/)
  * [Penn Treebank](http://www.cis.upenn.edu/~treebank/) ([tagging manual](ftp://ftp.cis.upenn.edu/pub/treebank/doc/manual/root.ps.gz))
  * [Prague Dependency Treebank](http://fairway.ms.mff.cuni.cz/~hladka/pdt2000/Corpora/PDT_1.0/index.html) ([tagging manual for analytical layer](http://shadow.ms.mff.cuni.cz/pdt/Corpora/PDT_1.0/Doc/aman-en/index.html))
  * [TIGER treebank for German](http://www.ims.uni-stuttgart.de/projekte/TIGER)
  * [Turin University Treebank for Italian](http://www.di.unito.it/~tutreeb/project.html)
  * [VISL Constraint-Grammar based Treebank for Danish (Arboretum)](http://visl.hum.sdu.dk/visl/da)

Here are some links to other relevant theories and resources:

  * [Treebank links from the TIGER project](http://www.ims.uni-stuttgart.de/projekte/TIGER/related/links.shtml)
  * [Tagging maual for an RST-tagged corpus of English by Marcu et al](http://www.isi.edu/~marcu/discourse)
  * [An Introduction to Rhetorical Structure Theory](http://www.sil.org/~mannb/rst/rintro99.htm)
  * [Daniel Marcu's Homepage](http://www.isi.edu/~marcu/), with links on RST-annotated corpora.
  * [Penn Discourse Treebank](http://www.cis.upenn.edu/~pdtb/) ([annotation manual](http://www.cis.upenn.edu/~pdtb/dltag-webpage-stuff/pdtb-tutorial.ps))
  * [LDC: Linguistic Annotation Tools and Formats](http://www.ldc.upenn.edu/annotation/)
  * [BySoc corpus of spoken Danish](http://www.id.cbs.dk/~pjuel/BySoc)
  * [FrameNet](http://www.icsi.berkeley.edu/~framenet/)
  * [Proceedings of the Treebanks and Linguistic Theories 2002 Workshop](http://www.bultreebank.org/Proceedings.html)

### Download ###

The Danish Dependency Treebank currently consists of 474 Parole texts, consisting of 5.540 sentences, 100.200 words, or 34.4% of the morphosyntactically annotated part of the Danish Parole corpus. The treebank is distributed under the GNU Public License, an open-source license. The treebank is encoded both in in [DTAG format](http://www.id.cbs.dk/~mtk/dtag) and in [TIGER-XML](http://www.ims.uni-stuttgart.de/projekte/TIGER/TIGERSearch/doc/html/TigerXML.html). You can download the treebank compressed with either "zip" (Windows) or "tar" and "gzip" (UNIX) by clicking on the appropriate link below.

  * [Danish Dependency Treebank version 1.0 (zip compression)](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/files/ddt-1.0.zip) (6,876 kB)
  * [Danish Dependency Treebank version 1.0 (tar.gz compression)](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/files/ddt-1.0.tgz) (4,639 kB)

The included [README file](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/files/README.html) describes how to install and use the treebank. You can also view a graphical visualization of the [first 18 texts](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/files/parole00-0.8.pdf) (233 kB) or [all 474 texts](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/files/parole-0.8.pdf) (5,681 kB). Alternatively, you can download the Danish Dependency Treebank from [Society for Danish Language and Literature](http://korpus.dsl.dk/e-resurser). If you have any questions about the treebank, please contact [mtk@id.cbs.dk](mailto:mtk@id.cbs.dk).


#### See also ####

