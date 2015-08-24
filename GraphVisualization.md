## Graph Visualization ##

The three graphs below show three possible visual representations of the same syntax graph: the arc layout used in the Danish Dependency Treebank, the layout used in classical dependency theory, and the phrase-structure layout used in discontinuous phrase-structure theories.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/graph1.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/graph1.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/tree2.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/tree2.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/tree3.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/tree3.png)

The treebank uses the ''arc layout'' on the left, where relations are drawn as circular arrows from heads to subordinate words, with a label below each arrow head that indicates the type of the relation (ie, "subj"=subject, "dobj"=direct object, etc). Arcs that encode primary dependencies (ie, complements and adjuncts without fillers, and gapping dependents) are shown above the words, arcs that encode fillers, landing sites, and coreference are displayed below the words. The word class is indicated with a PAROLE tag below each word (eg, NC, VA, etc).

Compared to the classical dependency layout and the phrase-structure layout, the arc layout has several advantages, listed below:

|  | Phrase-structure layout and classical layout | Arc layout |
|:-|:---------------------------------------------|:-----------|
| Words with multiple incoming edges | impossible                                   | no problem |
| Cyclic relations | impossible                                   | no problem |
| Discontinuities | awkward: it is hard to design good layout algorithms for discontinuous trees that ensure that discontinuous edges do not cross nodes in the tree, and that edge labels do not collide with node labels; in classical dependency graphs, this problem is solved by reordering the words, but then the original word order is lost | no problem: node labels and edges are drawn in separate areas in the drawing, so arcs may cross in the drawing, but they never collide with node labels |
| Multi-line and multi-page layout for long sentences | awkward: tree depth is often proportional to sentence length, so very long sentences tend to result in deep trees that are difficult to split across several lines and pages (ie, classical dependency graphs and phrase-structure graphs tend to be two-dimensional) | no problem: arc height rarely exceeds 10, even for very long sentences and texts, so long sentences result in arc graphs that are relatively flat and hence easy to split across several lines and pages (ie, arc graphs tend to be one-dimensional) |
| Empty categories | no problem                                   | no problem |
| Phrasal nodes | no problem                                   | awkward (but not used in a dependency framework) |

Since our linguistic theory uses multiple heads, cyclicity, discontinuities, and empty categories, but not phrasal nodes, the arc layout is the best choice of graphical representation in our framework -- especially because sentences in our corpus can be quite long (up to 70-90 words), and because we intend to eventually encode entire discourse structures in one graph, ie, we eventually need to create graphs that span entire texts. One relative advantage of the classical dependency layout and the phrase-structure layout is that most linguists are familiar with them. But the arc layout has been used in a few syntax theories, including [Word Grammar](http://www.phon.ucl.ac.uk/home/dick/enc-gen.htm).


#### See also ####

