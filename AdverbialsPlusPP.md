## Adverbials Plus P P ##

#### Expressions with verb + adverbial + PP ####

In the set of sample analyses all occurrences, but one (in ex 71), are analyzed in terms of pobj's as follows (cf. example 23):

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-08.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-08.png)

> There are two questions:

  * Is it reasonable to tag adverbials like "frem" frem as (heads of) pobj, when they are not prepositions?
  * Do all instances of [+ adverbial + PP](verb.md) have this structure?

> The first question is largely theoretical. As I see it, the alternatives is to analyze the adverb as a particle (part), where it forms a close connection with the verb, and as a modifier (mod) where it doesn't.

The answer to the second question seems to be negative: this is not a uniform construction, though we might decide to gloss over the differences in the treebank analyses, for reasons of simplicity and manageability. One can distinguish at least the following types of construction:

  * 1. The string forms a dependency chain where no element can be left out (without changing the meaning of the others)
    * ex: det **går ud over barnet**, de **fandt ud af det**, de **går ind for ideen**
    * Possible analysis:
> > ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-09.png)
    * Seems like [+ PP](adv.md) cannot be a modifier.
  * 2. The adverbial can be left out with minimal change of meaning, and [+ PP](adv.md) can be replaced with ["der"-Adv]:
    * ex: de **kørte hen i skoven**, de **gik oppe på loftet**, de **gik ned i kælderen**
    * jvf: de kørte i skoven, de kørte derhen.
    * Possible analysis:
> > ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-10.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-10.png)
    * Similar [+ PP](adv.md) expressions can occur as modifiers: de byggede hus **henne i skoven**
    * In some cases the string is ambiguous, e.g. "de **gik ned i kælderen**":
> > ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-11.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-11.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-12.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-12.png)
    * Q: is "i kælderen" a pobj in the right-hand example, or perhaps a modifier of the verb (as in type 4)?
  * 3. The noun (nobj of the preposition) can be left out (under recoverability), in which case the adverb and the preposition is written as one word.
    * ex: vi **gik uden om busken**, vi **stod over for skolen**, vi **blev inden for rammerne**
    * jvf: de gik udenom, de stod overfor, vi blev indenfor
  * 4. The PP can be left out, and there is no dependency relation between the adverb and the PP.
    * ex: den **røg ud under alle omstændigheder**, det har **ligget her i flere år**, vi **var med fra første færd**
    * jvf: den røg ud, den har ligget her, vi var med
    * Possible analysis:
> > ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-13.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/prep-13.png)
  * 5. The PP can be left out, but cannot be replaced with ["der"-Adv].
    * ex: de **skiftede ham ud med en anden**
    * jvf: de skiftede ham ud, **de skiftede ham derud.
  * 6. The adverbial can be left out or the PP can be left out, or both.
    * ex: de**satte sig ned på bænken**, hun**skrev det op på tavlen*** jvf: de satte sig ned, de satte sig på bænken, de satte sig.**

The marked paragraph above was written before the labels avobj and lobj came into this manual-world. These two labels solve some of the problems discussed above. All of the examples in the paragraph above would now be analysed as lobj, except "gå ud over": this would be analysed as avobj + pobj. Below follow some general remarks:

  * We have only tagged words tagged as RG as pobj when they clearly have an element of preposition. Often genuine (by word class) prepositions are tagged RG when they occur without an object. Here we have often tagged as pobj. Also "i\_gang", "herpå" (på dette), "derved" (ved dette) and the like are tagged pobj.
  * Usually the adverbial is tagged avobj or mod according to how close the connection is between the verb and the adverbial. The PP is tagged pobj or mod according to whether the expression is fixed or not (that is, could the preposition be exchanged with another preposition?).
  * When there is a locative-directional element in the adverbial, they are tagged as lobj. The PP is tagged mod or pobj according to whether the expression is fixed or not (that is, could the preposition be exchanged with another preposition?). See under [verbs ](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/verbs.html) -&gt; locative-directional objects for a more thorough description.


> See under [verbs ](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/verbs.html) for principles demarkating avobj/lobj/part/mod and pobj.


#### See also ####

