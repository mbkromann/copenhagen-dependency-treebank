## Names ##

A ''proper name'' cannot be inflected as a noun, but can be modified by other names and nouns. We distinguish between ''first names'' (eg, "Peter"), ''last names'' (eg, "Nielsen"), ''non-person names'' (eg, "Volvo", "Buller", "København"), ''titles'' (eg, "Hr."), and ''professions'' (eg, "doktor", "bager"). The analysis of proper names is guided by the following rules (with the edge type shown in bold):

  * **title**: a title can modify a following profession or last name.
  * **title**: a profession can modify a following last name, or a preceding first name.
  * **namef**: a first name can modify a preceding first name, or a following last name.
  * **namel**: a last name can modify a following last name.

Note that a profession is always an indefinite singular noun (eg, "bager", "sanger", "direktør"), and that definite nouns followed by a proper noun (eg, "komponisten Carl Nielsen") are analyzed as [restrictive apposition](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/#__Apposition). The principles above result in the analyses below:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-02.png)

In a name consisting of a proper name and a noun, the noun is analyzed as "nobj"-dependent of the proper name. In a name consisting of two proper names which cannot be analyzed in terms of first names and last names, the second name is analyzed as a "name"-dependent of the first name. This can be expressed by the following rules:

  * **nobj**: a name can sometimes take a following particular noun as its complement.
  * **name**: a non-person name can sometimes take a following particular non-person name as its complement.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-04.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-05.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-06.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-06.png)

Names of banks, companies, songs, etc. that are composed of ordinary nouns, are analyzed as if they were normal compounds. Thus, their status as names can only be deduced from their capitalization. An example is shown below:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/name-03.png)

The internal structure of proper nouns can be revealed by looking at how first and last names combine with titles and professions. Eg, we have "Peter bager", but "**Jensen bager", which indicates that "bager" may modify a preceding first name, but not a last name. Moreover, "**Peter Jensen bager" suggests that the last name is the head of the construction. This is confirmed by the observation that "hr. Jensen" and "hr. Peter Jensen" are quite natural, whereas "???hr. Peter" is highly unnatural. The same applies to "bager Jensen", "bager Peter Jensen", and "???bager Peter". In the external syntax, our analysis of titles and professions as modifiers to the proper noun is confirmed by examples like "Jeg kender bager/hr. Jensen", as contrasted with "**Jeg kender bager/hr.".**

In morphological composition where words are connected by a hyphen, titles are perfectly capable of modifying any following proper name ("bager-Peter", "direktør-Jensen"), and the same holds for almost any other noun ("fodbold-Peter", "kage-Jensen"), and infinitive verb ("svømme-Peter", "gruble-Jensen").


#### See also ####

