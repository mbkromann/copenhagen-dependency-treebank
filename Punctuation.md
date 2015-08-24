## Punctuation ##

**Punctuation signs (markers)** encode prosody, pauses, and segment boundaries in the input, and are not pronounced directly in spoken language. We distinguish between three kinds of markers, depending on the placement of the marker relative to the preceding and following word:

  * **begin-markers: ( [{ &lt; ' " -\*[[BR](.md)]''Marker attaches as clitic to following word without any intervening spaces (ie, as a proclitic) and modifies some word on its right whose presence licenses the marker.''
  ***end-markers: ? ! . , ; : ) ] } &gt; ' " -**[[BR](BR.md)]''Marker attaches as clitic to preceeding word without any intervening spaces (ie, as an enclitic) and modifies some word on its left whose presence licenses the marker.''
  ***separator markers: -**[[BR](BR.md)]''Marker is surrounded by spaces and modifies a word to its left or right which licenses the marker.''**

Note that some punctuation signs can be used as more than one kind of marker: eg, a single quote can be used as both kind of marker: eg, a single quote can be used as both begin-marker and end-marker (eg, "he 'flattered' her"), and "-" can be used as all three kinds of marker (eg, end-marker in "han- og hunkøn", begin-marker in "jernaldermand og -kvinde", and separator in "Bohr - a famous physicist - was born in Copenhagen"). Along another dimension, begin- and end-markers can be divided into two distinct classes:

  * **unary markers: ? ! . , ; : ' -**[[BR](BR.md)]''Licensed independently of any other marker.''
  * **binary markers: (...) [...] {...} &lt;...&gt; '...' "..."**[[BR](BR.md)]''Licensed as two matching begin- and end-markers.''

For **unary markers**, the direction of the dependency is determined by whether the marker is proclitic, enclitic, or a separator. We do not allow extraction of markers (ie, the governor and landing site of a marker must always coincide), so in order to determine the dependency, we need to look at all possible landing sites in the given direction, and determine which one of them licenses the marker. For example, the comma in the graph below is enclitic, so it must attach to an adjacent phrase whose head is on the left (eg, "løbe", "ville", or "at"). The comma rules for Danish mandate a comma after a finite verb with an overt subject, so the natural licensor of the comma is the finite verb "ville". Periods are always attached to the top node of the sentence, so in this case, the period is attached to "vidste".

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-01b.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-01b.png)

In the examples below, the continuity requirement on punctuation signs and the enclitic nature of "," and ":" (respectively) means that there is only one possible governor of "," and ":", namely "fløjtede" and "et". Again, the sentence final punctuation sign is analyzed as an adjunct of the top node in the sentence.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-02.png)

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-04.png)

In the relative clause below, the first comma is forced by continuity and the leftwards direction of the dependency, and the second comma is licensed by the verbal head of the relative clause (in Danish, all verb phrases containing a subject must end with a comma, unless the phrase ends in an even more prominent punctuation mark like ".", "!" or "?").

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-07.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/punct-07.png)


#### See also ####

