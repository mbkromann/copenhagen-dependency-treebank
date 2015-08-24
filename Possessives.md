## Possessives ##

Possessive pronouns are analyzed like determiners, except that the dependency between the possessive pronoun and its noun complement is labeled "possd" (=possessed) rather than "nobj". Possessives can also be formed by combining two noun phrases with the clitic possessive marker "s", which takes a "possr" (=possessor) noun phrase complement to its left, and a "possd" noun complement to its right. Unfortunately, in the PAROLE corpus, the clitic "s" is not tagged as a separate entity, but is glued on to the last word in the possessor phrase. We therefore have to encode our analysis as a dependency graph where the clitic-marked possessor noun phrase is the head, and the possessed noun phrase is a "possd" complement of the possessor:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-02b.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-02b.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-03b.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-03b.png)

Thus, in the second graph above, "et barns" (headed by "et") acts like a possessive pronoun, so "et" takes "far" as its "possd"-complement. Similarly, in the second graph, "min klassekammerats", "min klassekammerats mors", and "min klassekammerats mors chefs" (all headed by "min") all act like possessive pronouns that take their following noun as their "possd" complement. The final "possd" complement is optional, as shown in the predicative below:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-04b.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-04b.png)

In Discontinuous Grammar and treebanks that encode morphological structure, the possessive "s" should be analyzed as a separate lexeme. This gives the following more intuitive analyses, where the clitic possessive "s" has been detached from the last word in its possessor phrase:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-03.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/poss-04.png)

**Special possesives**[[BR](BR.md)] Some possesives are not so clearly possesive as the examples above. We have decided to analyse them as possesives, even if they have some characteristics of being modifying phrases instead. Here are some examples:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine63a.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine63a.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine64a.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine64a.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine65a.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine65a.png)

> The alternative modifier-analysis would look like this:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine63b.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine63b.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine64b.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine64b.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine65b.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine65b.png)

**Possesive or "fuge-s"?**[[BR](BR.md)] These examples could look like possesives, but they really are not. We analyse them as modifiers, and in fact they should be written and understood as one word, making it clear that the s is a "fuge-s": "en treværelses lejlighed" should be written "en treværelseslejlighed" according to the rules for danish orthography. Here are som examples of analysis:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine66.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine66.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine67.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine67.png)


#### See also ####

