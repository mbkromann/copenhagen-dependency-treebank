## File Format ##

There are obviously many ways to store the dependency analyses in the treebank. So far, the annotation program implements a very primitive XML-like data format. An example is shown below:

```

&lt;W msd="PP" gloss="He" in="1:subj|2:[subj]" out=""&gt;Han&lt;/W&gt;
&lt;W msd="VA" gloss="has" in="" out="-1:subj|1:vobj"&gt;har&lt;/W&gt;
&lt;W msd="VA" gloss="seen" in="-1:vobj" out="-2:[subj]|1:dobj"&gt;set&lt;/W&gt;
&lt;W msd="PD" gloss="it" in="-1:dobj" out=""&gt;det&lt;/W&gt;

```

The word itself is enclosed within the &lt;W&gt; tags, and the attributes of the &lt;W&gt; tag are used to encode arbitrary variables associated with the word, as well as incoming and outgoing edges to other words. The reserved attribute names are shown below:

  * **msd**: PAROLE tag
  * **lemma**: PAROLE lemma
  * **gloss**: English gloss
  * **lexeme**: lexeme name in the lexicon
  * **in**: list of in-coming edges of the form "$rpos:$edge", separated by "|", where $rpos is the relative position of the governor ("+1" means next word, "+2" two words ahead, "-1" previous word, etc.), and $edge is the type of the edge.
  * **out**: list of out-going edges of the form "$rpos:$edge", separated by "|", where $rpos is the relative position of the dependent.

The annotation format is an extension of the notation used in the Danish PAROLE corpus. The tagging software treats all non-&lt;W&gt; tags as comments, so these tags are left unchanged by the software.

In the future, we would like to add support for TIGER XML. In the distant future, we would also like to add support for the ATLAS interchange format.


#### See also ####

