## Preposition Objects ##

We use "pobj" for complements headed by a preposition. Some prepositional complement express a (physical) location or direction, others express more abstract relations, including the "af"-phrase in a passive construction.

  * Hun lagde den **på bordet**.(In this example, "på" would now be analysed as lobj to the verb (see the paragraph on lobj). Alternatively it should be analysed as a modifier, since there is no close connection between the verb and the preposition: "Hun lagde den på bordet/i spanden/under hovedpuden". Also "på bordet" goes with many other verbs as well).
  * Han ventede **på dem**.
  * Sagen blev undersøgt **af politiet**.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-04.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pobj-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pobj-01.png)

Further special examples:

  * Det virkede/lød/så ud som\_om hun var glad.
  * Hun lader/opfører sig som\_om hun var hjemme.
  * Hun stemte ja til forslaget. ("til" pobj til "stemme")
  * Han sagde nej til tilbuddet. ("til" pobj til "sige")

**The preposition "med"**

Usually "med" is analysed as mod to the verb, but fixed expressions are exceptions to this rule.

  * **være med**:
    * "være med": "med" is pred to "være"
    * "være med til": "til" is pobj to "med".
  * **gå med**:
    * "gå med nogen", "gå med i byen": "med" mod to "gå"
    * "gå med hunden", "gå med [beklædning]", "det går [phrase](adjectiv.md) med noget", "[tiden](tiden.md) går med noget": "med pobj to "gå"
    * "gå med til noget" ("accept"): "med" pobj to "gå", "til" pobj to "med"
  * **komme med**:
    * "komme med et sted hen": "med" mod to "komme"
    * "komme med et udspil", "komme med [phrase](adjectiv.md) ud af det med nogen": "med" pobj to "komme"
  * **følge med**:
    * "følge med (nogen)": "med" mod to "følge"; "med" can be analysed as part, only if "med" cannot take an object in the particular construction
    * "følge noget op med noget andet": "med" pobj to "følge"
  * **skulle med**
    * "det skulle med i billedet": "med" mod to "skulle", "i" mod to "med"
  * **have med**:
    * "have noget med": "med" mod to "have"
    * "at have det med at grine": "med" pobj to "have"
    * "have med noget at gøre": "at" dobj to "have", "gøre" vobj to "at", "med" pobj " to "gøre", "noget" nobj to "med"
  * **løbe med**:
    * "løbe med nogen", "løbe med et sted hen": "med" mod to "løbe"
    * "løbe med sladder": "med" pobj to "løbe"
  * **synge med**: "med" mod to "synge"
  * **høre med**: "med" mod to "høre"
  * **se med**: "med" mod to "se"
  * **spille med**: "med" mod to "spille"

To distinguish prepositional complements from prepositional modifiers, we use the following diagnostics (adapted from Philp (1999)).

  * **generality**: prepositional complements only apply to particular verbs, whereas prepositional modifiers tend to apply to all verbs.
  * **fixed preposition**: In prepositional complements that express abstract relations the preposition is fixed in the sense that it cannot be replaced with a semantically similar preposition (without a non-proportional change in meaning). This is not true for prepositional modifiers.
    * Han ventede **på dem/??i dem** (pobj)
    * Han ventede **på stationen/i gården** (mod)
  * **linear order**: Prepositional complements tend to precede prepositional modifiers:
    * Han venter på dem på stationen.[[BR](BR.md)] --&gt; ??Han venter på stationen på dem. ("på dem" is pobj, "på stationen" is mod)  This really is only a tendency and cannot at all be used as an analysing guideline: Search in our tagged corpus reveals that a search for the construction verb + prepositional modifier + prepositional complement comes out with about 50 examples. A search for the construction verb + prepositional complement + prepositional modifier comes out with about 120 examples. The complement + modifier word order is clearly more frequent, but the word order modifier + complement is on the other hand quite common.


#### See also ####

