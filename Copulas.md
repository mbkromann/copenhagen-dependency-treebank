## Copulas ##

**Copula constructions:** These are basically covered in the sections on 'pred' and 'expl'. One remaining question is whether we should distinguish between predicative and equative/specificational/identificational copula clauses, when both dependents are nominals:

  * Han er en stærk svømmer. (predicative)
  * Den stærkeste svømmer på holdet er ham. (specificational)
  * Han er Peter. (equative)
  * Peter er ham. (equative)
  * Det er Peter. (identificational)

Analysis of "som X"-constructions is done as follows: (1) Analyze "som X" as a relative, if possible:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-03.png)

(2) If you can insert "så vel" ("as well") in front of "som", then analyze "som X" as a coordination:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-06.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-06.png)

(3) If "som X" functions like a predication "er X" (ie, "historien som fortalt" ---&gt; "historien er fortalt" / "story as told" ---&gt; "story is told", then "som X" is analyzed just like "er X" ). -- that is, "X" is a predicative "pred", unless "X" is a verb, in which case we choose "vobj" instead:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-04.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/som-05.png)

  * Moskva er ganske rigtigt en by i Rusland, som hævdet af Marie.

If the verb is finite, the construction is analyzed as a relative clause; if the verb is perfect, "som" is analyzed as the head, and the verb as the "pred" complement of "som".

The English Dependency Treebank distinguishes equative from predicational copular clauses, using an inversion test (equatives invert, predicational clauses do not) and an embedding test (predicational clauses embed as small clauses without "be", equatives do not). In predicational clauses the (head of the) post-copula phrase is the head of the clause, and the copula and the subject are its dependents. In equatives, the copula is the head, and the post-copular clause is an object.

The Penn Treebank treats all copular clauses as predicational, including ones with two nominals. The post-copular phrase is uniformly analyzed as XP-PRD.

The Corpus Gesproken Nederlands does not discuss copula clauses explicitly. Some predicational copula clauses are given under the discussion of the complement label 'PREDC'.

This leaves two options for the Danish Dependency Treebank: (1) Treat all copula clauses as predicational -- tag all predicate complements as 'pred'. (2) Distinguish predicational copular clauses from equative/specificational/identificational copular clauses -- tag the complement of the former as 'pred' and the complement of the latter as 'dobj'.


#### See also ####

