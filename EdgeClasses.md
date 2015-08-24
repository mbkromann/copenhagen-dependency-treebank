## Edge Classes ##

The treebank makes use of the following complement edges, shown along with the word classes that typically act as governors and complements in such constructions ("?" indicates that any word class may be used):

  * **aobj (?-&gt;A):** adjectival object
  * **avobj (?-&gt;RG/SP):** adverbial object
  * **conj (CC/?-&gt;?):** conjunct of coordinator
  * **dobj (V-&gt;N/P):** direct object
  * **expl (V-&gt;der/RG):** expletive subject
  * **fobj (PT-&gt;filler):** filler object
  * **iobj (V-&gt;N/P):** indirect object
  * **lobj (V-&gt;SP/RG):** locative-directional object
  * **nobj (P/N/SP-&gt;N):** nominal object
  * **numa (M-&gt;M):** additive numeral complement.
  * **numm (M-&gt;M):** multiplicative numeral complement.
  * **part (V-&gt;SP/P):** verbal particle
  * **pobj (V-&gt;SP):** prepositional object
  * **possd (genitive-&gt;N):** possessed in genitive constructions
  * **possr (genitive-&gt;N):** possessor in genitive constructions (only used in morphological analysis)
  * **pred (V-&gt;A/N):** subject or object predicative
  * **qobj (V/?-&gt;?):** quotation object
  * **subj (V-&gt;N/P):** subject
  * **vobj (V/N/SP-&gt;V):** verbal object

and the following adjunct edges:

  * **appa (N-&gt;N):** parenthetical apposition
  * **appr (N-&gt;N):** restrictive apposition
  * **coord (?-&gt;CC):** coordination
  * **err (?-&gt;?):** unanalyseable part of the sentence or phrase (used for syntactic errors)
  * **list (?-&gt;?):** next element in unanalyzed sequence of words
  * **mod (?-&gt;?):** modifier
  * **modo (V-&gt;?):** direct object-oriented modifier
  * **modp (?-&gt;?):** parenthetical modifier
  * **modr (?-&gt;?):** restrictive modifier
  * **mods (V-&gt;?):** subject-oriented modifier
  * **name (NP-&gt;NP):** modifying proper name
  * **namef (NP-&gt;NP):** modifying first name
  * **namel (NP-&gt;NP):** modifying last name
  * **pnct (?-&gt;XP):** punctuation modifier
  * **rel (N-&gt;V):** relative clause modification
  * **title (NP-&gt;N):** title of person
  * **xpl (?-&gt;?):** explification of previous phrase

In addition, there are edges used for encoding landing sites, coreference, fillers, and gaps:

  * **land (?-&gt;?):** landed node
  * **xland (?-?):** external landed node (which is not a local dependent)
  * **ref (?-&gt;?):** anaphoric reference from antecendent to anaphor
  * **[''dtype''] (?-&gt;?):** filler dependency of type ''dtype'' between a governor and a filler
  * **&lt;''dtype''&gt; (?-&gt;?):** gapping dependency of type ''dtype'' between a dependent and an elided head in an elliptic coordination, encoded as a dependency between the dependent and the governor of the elided head

The following edges are not used in the tagging, but are reserved for future annotations:

  * **temp (?-&gt;?):** temporal adjunct
  * **loc (?-&gt;?):** locative adjunct
  * **fill (?-&gt;filler):** dependency from filler licensor to filler (subtype of **land**)
  * **gap (?-&gt;filler):** dependency from a gap licensor to the gap in a gapping coordination
  * **relz (N-&gt;Ñ):** a landing site dependency between a relativized noun and the relative pronoun (or PP containing a relative pronoun) which comes right after the relativized noun.

The edges used in the treebank are ordered in a type hiearchy:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/edges.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/edges.png)

Complements are subdivided into the following types:

Adjuncts are subdivided into the following types:


#### See also ####

