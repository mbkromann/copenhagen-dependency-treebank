The Copenhagen Dependency Treebanks are a set of linguistically annotated text collections (treebanks) on the basis of the dependency-based grammar formalism Discontinuous Grammar. The treebanks created in the project can be used to train natural language parsers, syntax-based machine translation systems, and other statistically based natural language applications.

The project hosts the following treebanks:

  * the 100,000 word **Danish Dependency Treebank**, which was used as training material in the CoNLL shared task in 2006;
  * the 95,000 word **Copenhagen Danish-English Dependency Treebank**;
  * work-in-progress with respect to **Copenhagen Dependency Treebanks** for Danish, English, German, Italian, and Spanish, including a number of discourse-annotated texts.

The treebanks are released to the computational linguistics / natural language processing community under various open-source licenses: the Gnu Lesser Public License for Libraries, the MIT License, and the Creative Commons License (whatever suits your needs best). For more information about the project, please visit our [CDT](CDT.md) page.

## Related projects ##

The Copenhagen Dependency Treebanks have been converted to other formats. Most notably: 

  * [The Universal Dependencies Danish DDT](https://universaldependencies.org/treebanks/da_ddt/index.html) ([GitHub](https://github.com/UniversalDependencies/UD_Danish-DDT)): the original Danish Dependency Treebank has been 
    mapped to Universal Dependency annotations, which seek to provide a standardized annotation of morphology and syntax across many different languages. 
  * [CDT2012 TreeX mapping](https://github.com/mbkromann/copenhagen-dependency-treebank/raw/master/CDT2012/treex/conversion_from_tag/slides.pdf): Zdenek Zabokrtsky has cleaned up the parallel CDT treebanks and mapped them into [TreeX](http://ufal.mff.cuni.cz/treex) format. His converted files are located in the CDT2012 folder. 
  * [SpaCy pre-trained models for Danish](https://explosion.ai/blog/spacy-v2-3): pretrained parsing models based on the Universal Dependencies Danish DDT. 

If you merely want to use the Danish Dependency Treebank to train a parser for Danish, you probably want to use the Universal Dependencies Danish DDT, since 
Universal Dependencies are a standard resource supported by a host of tools, including pre-trained parsers such as SpaCy. The TreeX mapping may be your best bet if you want to explore the parallel annotations. 

However, the Universal Dependencies anotations differ significantly from the original Danish annotation in that the Copenhagen Dependency Treebanks systematically treat function words like determiners, auxiliaries, modals, and prepositions as heads, whereas Universal Grammar systematically uses content words as heads and function words as modifiers. 

I still think the CDT treebanks are more correct and principled from a linguistic viewpoint, grounded as they are in the dependency theory [Discontinuous Grammar](https://github.com/mbkromann/copenhagen-dependency-treebank/raw/master/docs/2006-buch-kromann-disssertation.pdf). So take a closer look at the treebanks and Discontinous Grammar if you are more interested in linguistics than in parsing, or you want to explore some of the many features of the DDT annotation that are not preserved in the UD-DDT, such as secondary dependencies, discourse annotation, and coreference annotation (be warned that these annotations are still in a somewhat rudimentary state, since I left the field of computational linguistics before their completion). 

## Quick links ##

  * [Overview](https://github.com/mbkromann/copenhagen-dependency-treebank/wiki/CDT): description of the treebanks, download, and publications.
  * [DTAG installation](https://github.com/mbkromann/copenhagen-dependency-treebank/wiki/DTAGINSTALL): how to install DTAG on your Linux/UNIX machine
  * [Download](https://github.com/mbkromann/copenhagen-dependency-treebank/source/checkout): download via subversion
  * [Manual](https://github.com/mbkromann/copenhagen-dependency-treebank/raw/master/manual/cdt-manual.pdf): annotation manual with relations, agreement scores and status (auto-generated from [spreadsheet](http://spreadsheets.google.com/ccc?key=0ArjTKYTQS1lWcnNUWGJrX3lZTkxDc3QxYmlqWlRXQ1E&hl=en))
  * [Examples](https://github.com/mbkromann/copenhagen-dependency-treebank/raw/master/docs/cdt-examples.zip): a zip file with examples of annotated texts in PDF and .tag/.atag format.
  * [DTAG HOWTO](https://github.com/mbkromann/copenhagen-dependency-treebank/wiki/DTAGHOWTO): description of the commands in the DTAG tool
  * [CDT HOWTO](https://github.com/mbkromann/copenhagen-dependency-treebank/wiki/CDTHOWTO): description of how to perform common tasks in the CDT project (project-internal)

## Example ##

The example below shows a small text excerpt from the Copenhagen Dependency Treebank for English annotated with intra-sentence dependencies, discourse dependencies, secondary dependencies (filler-gap constructions), and coreference annotation. In Discontinuous Grammar, the underlying dependency theory, discourse structures are assumed to form one big dependency tree with primary dependencies, supplemented with additional linguistic relations that encode other phenomena (such as coreference).  The primary dependency tree may be discontinuous (non-projective), but there is an underlying continuous (projective) surface tree which controls word order and can be deduced from the dependency tree. 

<img src='https://github.com/mbkromann/copenhagen-dependency-treebank/blob/master/figs/iorn-0531.kort.en.png' title='Syntax-discourse annotation from the English CDT treebank' width='800'>
