# The Copenhagen Dependency Treebanks #

The purpose of the Copenhagen Dependency Treebank project is to create linguistically annotated text collections (treebanks) on the basis of the dependency-based grammar formalism Discontinuous Grammar (Buch-Kromann 2009). The treebanks created in the project can be used to train natural language parsers, syntax-based machine translation systems, and other statistically based natural language applications. The treebanks are based on a unified dependency annotation, where texts are analyzed as a single dependency structure that spans all levels of analysis, from morphology to discourse.

The project has so far resulted in three sets of treebanks:

  * **CDT1:** The Danish Dependency Treebank (100,000 words), which was used as training material in the CoNLL 2006 shared task.
  * **CDT2:** The Danish-English Parallel Dependency Treebank (95,000 words).
  * **CDT3:** The Copenhagen Dependency Treebanks for Danish, English, German, Italian and Spanish (2x100,000 + 3x60,000 words, work-in-progress).

The main status of the treebanks is listed below.

| **Treebank** | **Languages** | **Annotation** | **Word tokens** | **Status** |
|:-------------|:--------------|:---------------|:----------------|:-----------|
| CDT1         | Danish        | part-of-speech, syntax | 100,000         | complete   |
| CDT2         | Danish to English | part-of-speech, syntax, word alignments | 95,000          | complete   |
| CDT3         | Danish to English, Italian, Spanish, German | part-of-speech, syntax with extended adverbial annotation, word alignments, discourse structure, anaphora, morphology | 2x100,000 + 3x60,000 expected | in progress |

CDT3 uses a much improved annotation scheme, compared to the annotation scheme used in CDT1+2. We expect CDT3 to be completed in the spring of 2011.

## License ##

The treebanks are released to the computational linguistics and natural language processing community under an open-source license (the [GNU General Public License](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/LICENSE-GPL)). The license means that you can use the treebank freely, both for research and commercially, but if you create or distribute a linguistic resource that is derived from the treebanks, either on its own or as a part of a software application or service, the derived linguistic resource must be made freely available under the GPL. For borderline cases and special licensing needs, please contact Matthias Buch-Kromann <matthias@buch-kromann.dk>.

The [Danish Society for Language and Literature](http://www.dsl.dk) owns the copyright to the underlying Danish PAROLE corpus, but has agreed to dual-license PAROLE-DK under the  GPL as well so that it can be distributed along with the treebank. The PAROLE-DK corpus, as well as other corpus resources for Danish, can also be downloaded from DSL's website.

## Downloading the treebank ##

The treebanks can be downloaded from the [CDT Google Code repository](http://code.google.com/p/copenhagen-dependency-treebank/source/checkout) by means of subversion. You can also [browse the treebank sources online](http://code.google.com/p/copenhagen-dependency-treebank/source/browse/#svn/trunk). We plan to release the treebanks in a variety of formats (CONLL-2007, TigerXML). Please contact us if you are interested in obtaining the treebanks in a particular format, and we will do our best to help you.

## Documentation ##

The currently best description of the treebank is given in Buch-Kromann et al (2009) and Buch-Kromann and Korzen (2010). The relations used in the trebank, including the current annotation status and confusion scores for individual relations, are described in detail in our most recent draft [annotation manual](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/manual/cdt-manual.pdf), a work-in-progress which is undergoing major revisions at the moment. You can download a [zip-file](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/cdt-examples.zip) with samples of annotated texts in PDF and .tag/.atag format. We have also created a [treebank map](http://treebank.dk/map) which can be used to quickly get statistics and samples of the dependency relations used in the current treebank (it may be slightly outdated). Buch-Kromann (2010c) ([pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-mbk-esslli.pdf)) describes the link between the annotations and Discontinuous Grammar, the underlying linguistic theory. The DTAG annotation tool is described in Buch-Kromann (2010b) ([pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-wp-dtag.pdf)) and the [DTAG HOWTO](DTAGHOWTO.md). Finally, you can [browse the treebank sources online](http://code.google.com/p/copenhagen-dependency-treebank/source/browse/#svn/trunk).

## Feedback and bug reports ##

Please let us know if you use the treebanks in commercial products or open-source products, by sending a mail to us - this is the best way you can support us and help us make the case to our sponsors that our treebanks have been used to create useful language technology.

Please also contact us with feedback and bug reports. We are very interested in improving the quality of the annotations, so if you can send us a list of errors and potential problems in the treebanks, and perhaps even fixes to these problems, we will try to incorporate them in the treebanks. Emails should be directed to:

> Matthias Buch-Kromann <[cdt@buch-kromann.dk](mailto:cdt@buch-kromann.dk)>

## Acknowledgements ##

  * The Danish source texts and the Danish part-of-speech tags were created by the PAROLE-DK project (Keson 2000a,b) by the [Danish Society for Language and Literature](http://www.dsl.dk).
  * CDT1 was funded by an internal grant from the Copenhagen Business School.
  * CDT2 was funded by a grant from the Strategic Research Council in Denmark (via the Danish Program Committee for IT research)
  * CDT3 was funded by grants from the Free Research Council in Denmark and from the Copenhagen Business School.

## References ##

If you use the treebanks in scholarly work, please cite them as follows:

  * **CDT1**: Please cite one of: Kromann (2003), Buch-Kromann (2006), or Buch-Kromann (2009). When using the Danish PAROLE-DK corpus and its part-of-speech tags (the "msd" feature in Danish), please cite Keson (2000a) and link to [DSL](http://korpus.dsl.dk/e-resurser/parole-korpus.html).
  * **CDT2**: Please cite Kromann et al (2007)
  * **CDT3**: Please cite: Buch-Kromann et al (2009) or Buch-Kromann and Korzen (2010a)


Iørn Korzen and Matthias Buch-Kromann, 2011. Anaphoric relations in the Copenhagen Dependency Treebanks. To be presented at Beyond Semantics 2011, DGfS Workshop, Göttingen, February 23-25, 2011. [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-beyondsem-anaphora.pdf)

Matthias Buch-Kromann, Daniel Hardt, and Iørn Korzen, 2011. Syntax-centered and semantics-centered views of discourse. Can they be reconciled? To be presented at Beyond Semantics 2011, DGfS Workshop, Göttingen, February 23-25, 2011. [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-beyondsem-discourse.pdf)

Matthias Buch-Kromann, Morten Gylling-Jørgensen, Lotte Jelsbech Knudsen, Iørn Korzen, and
Henrik Høeg Müller, 2010. _The inventory of linguistic relations used in the
Copenhagen Dependency Treebanks._ Center for Research and Innovation in Translation and Translation Technology, Copenhagen Business School. [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/manual/cdt-manual.pdf)

Matthias Buch-Kromann, 2010c. Open challenges in treebanking: some thoughts based on the Copenhagen Dependency Treebanks. Invited paper at the Annotation and Exploitation of Parallel Corpora Workshop, Tartu, December 1-2, 2010. [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-aepc-mbk.pdf)

Matthias Buch-Kromann, 2010b. Dependency grammar for computational linguists.
Course notes for ESSLLI 2010 in Copenhagen. [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-mbk-esslli.pdf)

Matthias Buch-Kromann, 2010a. The DTAG treebank tool. Annotating and querying treebanks and parallel treebanks. Working paper. [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-wp-dtag.pdf)

Matthias Buch-Kromann and Iørn Korzen, 2010. _The unified annotation of syntax and discourse in the Copenhagen Dependency Treebanks_. In Proc. of Linguistic Annotation Workshop, ACL 2010, Uppsala. [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-law-short-mbk-ik.pdf) [poster](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-law-poster-mbk-ik.pdf)

Matthias Buch-Kromann, Iørn Korzen, and Henrik Høeg Müller, 2009. Uncovering the 'lost' structure of translations with parallel treebanks. In special issue of Copenhagen Studies of Language, vol. 38, pp. 199-224: Fabio Alves, Susanne Göpferich, and Inger Mees (eds.). _Methodology, Technology and Innovation in Translation Process Research._ [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2009-csl-cdt.pdf)

Matthias Buch-Kromann, 2009. _Discontinuous Grammar. A dependency-based model of human parsing and language learning._ VDM Verlag. Republication of Buch-Kromann (2006).[link](http://www.amazon.co.uk/Discontinuous-Grammar-dependency-based-language-learning/dp/3639172817/ref=sr_1_1?ie=UTF8&s=books&qid=1267188603&sr=8-1)

Matthias Buch-Kromann, Jürgen Wedekind, and Jakob Elming, 2007. _The Copenhagen Danish-English Dependency Treebank v. 2.0._ Parallel dependency treebank for Danish-English with 100,000 words based on the Danish Dependency Treebank. [link](http://www.buch-kromann.dk/matthias/cdt2.0)

Matthias Buch-Kromann, 2007. _Computing translation units and quantifying parallelism in parallel dependency treebanks._ Linguistic Annotation Workshop (LAW-2007) at ACL-2007, June 28-29, Prague. [pdf](http://www.aclweb.org/anthology/W/W07/W07-1512.pdf)

Matthias Buch-Kromann, 2006. _Discontinuous Grammar. A dependency-based model of human parsing and language learning._ Dr.ling.merc. dissertation, Copenhagen Business School. 432+xvi pp. [link](http://www.buch-kromann.dk/matthias/thesis)

Matthias Trautner Kromann, 2003. _The Danish Dependency Treebank and the DTAG treebank tool._ In Proceedings of the Second Workshop on Treebanks and Linguistic Theories (TLT 2003), 14-15 November, Växjö.  pp. 217-220. [pdf](http://www.buch-kromann.dk/matthias/files/030730-tlt-norfa.pdf)

Britt Keson, 2000a. _Vejledning til det danske morfosyntaktisk taggede
PAROLE-korpus_. Technical report, Det Danske Sprog- og Litteraturselskab (DSL). [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/paroledoc_dk.pdf)

Britt Keson, 2000b. _The Danish Morphosyntactically Tagged PAROLE Corpus_. English summary of Keson (2000a), Det Danske Sprog- og Litteraturselskab (DSL). [pdf](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/paroledoc_en.pdf)