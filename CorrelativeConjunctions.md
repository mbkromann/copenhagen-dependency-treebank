## Correlative Conjunctions ##

Correlative conjunctions ("både - og", "enten - eller", "hverken - eller", "dels - dels", "ikke - men", etc.) are analyzed as obligatorily extracted modifiers of the coordinator.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-11.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-11.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-13.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-13.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-12.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-12.png)

In the construction "dels X, dels Y", the first "dels" is analyzed as a correlative conjunction, the second "dels" is analyzed as a coordinator:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-21.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-21.png)

The unique construction "jo ..., jo ..." ("The ..., the ...") could be described as a coordinator with a correlative conjunction, yet this analysis seems wrong, since the first "jo" cannot be placed arbitrarily in the sentence, like "både" in "både ... og", "hverken" in "hverken ... eller", and the first "dels" in "dels ... dels". Instead vi have chosen the following analysis:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine02.png) This analysis has the virtue, that the "jo"s are interconnected and the second "jo" functions as the head of the sentence. This makes it possible for the computer to recognize this very unique construction.

> Another possibility is to analyse the "jo ..., jo ..."-construction as follows:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine01.png)

The major problem with this anlysis is, that "jo..., jo..." are not linked by a direct dependency, although they intuitively seem strongly connected.

A parallel expression to "jo ..., jo ..." is "jo ..., desto ...", e.g. "Jo færre han lytter til, desto større betydning får de". We believe this should be analysed just like the "jo ..., jo ..."-construction:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine91.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine91.png)

We have decided to analyse "ikke blot x, men også y" as a correlative conjunction:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine61.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine61.png)

The phrase "såvel x som y" should also be analysed as a correlative conjunction:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine72.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine72.png)

Instead of using the first conjunct as the head of the coordination, an alternative analysis is to analyze the coordinator as the head of the coordination. This analysis is however problematic when we look at extraction data: in extractions, it is possible to separate the first conjunct from the coordinator, but the second conjunct is always adjacent to the coordinator. This suggests that the coordinator and the second conjunct form a phrase. Thus, we have discontinuous coordinations and extractions from the first conjunct such as:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-22.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-22.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-23.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/coord-23.png)


#### See also ####

