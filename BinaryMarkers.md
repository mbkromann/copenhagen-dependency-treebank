## Binary Markers ##

**Binary markers** are always attached to the lowest governor that dominates all words between the two markers. Thus, the parentheses in the first example below are attached to the lowest governor that dominates both "tror" and "vi", eg, "tror". Similarly, the single quotes in the second example are attached to the lowest governor that includes "Så du hende igen?", ie, they are attached to "Så". The question mark in the quotation is analyzed as a modifier of the top word of the quotation, ie, "Så".

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-06.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-06.png)

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-05.png)

Principly binary markers should always be attached to the same governor. In practice, though, we have followed another principle, that collides with this principle: The analysis stops at the end of a sentence, usually marked by a period. That is, even though some part of sentence A refers to some part of sentence B, this is not shown; and even though two sentences share a head, this is not shown in the analysis either. For binary markers this means that parentheses that surround more than one full sentence are in practice attached to two different heads: one in sentence A and one in sentence B. With quotation marks the same happens, if the quotated part is more than one full sentence. In that case we attach the starting quotation mark to the head of the first sentence in the quotation, and we attach the ending quotation mark to the head of the second sentence in the quotation. Here is an example:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine90.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine90.png)

> In a "cross-sentence analysis" we would attach both quotation marks to "kan". But since this is not allowed by the current guidelines, we have to attach the first quotation mark to the head of the first sentence, "kan", and the second to the head of the second sentence, "men". If the treebank analyses are ever to be extended, so that the analyses will stretch accross sentence border, this will off course be corrected.


#### See also ####

