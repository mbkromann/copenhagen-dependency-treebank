## Appositions ##

The treebank distinguishes between ''parenthetical apposition'' and ''restrictive apposition''. In **parenthetical apposition**, a definite noun is modified by a following coreferential NP (with edge "appa"), which is parenthetical in the sense that the semantic reference of the first NP can be determined from the first NP alone -- ie, the second NP is not needed to determine the reference, but merely provides additional information about the first NP. Parenthetical apposition is easily recognized because the apposition is always enclosed in commas, dashes, or parentheses. An example of parenthetical apposition is shown below:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-01.png)

A parenthetical apposition may also modify a verb, if the apposition can be used predicatively about the infinitival version of the verb phrase. Eg, "Han var vred, en dårlig egenskab" (="He was angry, a bad trait") is possible because "At være vred er en dårlig egenskab" (="To be angry is a bad trait") is possible. Some examples are shown below:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-05.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-06.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-06.png)

In **restrictive apposition**, a definite NP is modified by a following noun phrase (with edge "appr"), which must denote a name. The second NP is normally more specific in terms of semantic reference than the first NP, and the two NPs are never separated by any punctuation.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-04.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-08.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-08.png)

Note that the first NP is always definite in this construction: If it is indefinite, it should probably be analyzed as a title that modifies a [proper name](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/#Names). Note also that many pronouns allow a proper noun as their nominal object, and that a proper noun should be analyzed as "nobj" if possible, so that the analysis with restrictive apposition only applies where the pronoun already has an "nobj". Compare:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-09.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-07.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/appo-07.png)

In parenthetical appositions, agreement data support the analysis of the first NP as the head:

  * Romanen, et værk på 800 sider, var uforståelig/**uforståeligt.
  * Huset i Rødovre, en gammel kasse, var grimt/**grim.
  * årsagen -- et defekt kontrolsystem -- var uheldig/**uheldigt.**

In restrictive appositions, agreement data seem to support the analysis of the first NP as the head:

  * Huset "Roligheden" er **pæn/pænt.[[BR](BR.md)] Ejendommen "Roligheden" er pæn/**pænt.
  * Goethes hovedværk "Faust" var **genial/genialt.[[BR](BR.md)] Goethes roman "Faust" var genial/**genialt.
  * Aktieselskabet Den Danske Bank er **god/godt at investere i.[[BR](BR.md)] Virksomheden Den Danske Bank er god/**godt at investere i.

However, the agreement data for restrictive apposition are somewhat confusing when the appositional phrase denotes a person. In these cases, the entire phrase preferably receives common gender, and sounds slightly more odd when it receives neuter gender from its head noun:

  * Geniet Einstein var altid opfindsom/?opfindsomt.[[BR](BR.md)] Fysikeren Einstein var altid opfindsom/**opfindsomt.
  * Folketingsmedlemmet Ole Espersen var ærlig/?ærligt.[[BR](BR.md)] Ministeren Ole Espersen var ærlig/**ærligt.

This can perhaps be explained by a strong semantic preference for assigning common gender to words that denote persons, regardless of their grammatical gender. This explanation is supported by a similar observation for neuter NPs that appear on their own, without apposition:

  * Folketingsmedlemmet var uenig/?uenigt med ministeren.
  * Barnet var uenig/?uenigt med sine forældre.
  * Pop-idolet var vred/?vredt på sine fans.


#### See also ####

