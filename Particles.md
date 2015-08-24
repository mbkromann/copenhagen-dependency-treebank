## Particles ##

We use the label part for verbal particles. These are adverbs or prepositions without a complement, which form a close semantic union with the verb.

  * Han skrev kontrakten **under**.
  * De gav **op**.
  * De gik sagen **igennem**.
  * Giften slog hunden **ihjel**.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/particle-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/particle-02.png)

The particle is obligatory, in the sense that leaving it out or exchanging it for a regular prepositional phrase results in a different semantics of the verb:

  * Han skrev kontrakten [= He wrote the contract]
  * Han skrev kontrakten **under** [= He signed the contract; "under" is part]
  * Han skrev kontrakten **under** bordet [= He wrote the contract under the table; "under" is mod]

Some, but not all,

particles are separable prefixes, which together with the verb form a synonymous complex word form:

  * skrive under ~ underskrive
  * give op ~ opgive
  * melde sig til ~ tilmelde sig ["til" might be a 'pobj', since it can occur with a 'nobj' "melde sig til kurset"](though.md)

The following principles can help distinguish particles from adverbial objects (avobj) and prepositional objects (pobj):

  * **Word class:** Avobj applys ''only'' to adverbs, not to prepositions. Pobj applys ''only'' to prepositions. Particles on the other hand apply to both adverbs (e.g. "give op") and prepositions (e.g. "skrive under".
  * **Prefixes:** Particles are separable prefixes, which together with the verb form a synonymous complex word form (skrive under -&gt; underskrive, give op -&gt; opgive). Adverbial objects cannot do this (at least not with the preservation of meaning). Prepositional objects cannot do this either.
  * **Objects:** Particles do not take an object. If it takes an object it is converted into a prepositional object. Prepositional objects always carry the possibility of an object ("melde sig til" -&gt; "melde sig til ''kurset''"). Adverbial objects often combine with a preposition (ind i, op på), which is tagged as either mod or pobj. See above under Avobj.

For particles that are prepositions by word class an alternative analysis is to tag them as pobj, with the requirement that they be used without a complement. This complicates the analysis of prepositions, which are normally required to take a complement. For particles that are adverbs, an alternative analysis is to tag them as modifiers.

Some difficult cases from the set of sample analyses (see also the section on adverbial + PP in the chapter on preposition):

  * De var **med**. [ex. 29, "med" is probably 'part' and not 'pred', since "med" is not used with the other copula verbs with this meaning (??synes med, **blive med), but it is used with non-copula verbs with the same meaning (komme med, gå med, etc.)]"Være med" is analysed as pred, since "være" always takes a pred. See under prepositional objects above.
  * Jeg har svært ved at følge**med**. [ex. 52, "med" is probably 'part', even though "med" can occur with an nobj ("følge med dem"). These could be considered two different constructions. In the first "med" is `part', in the other it is `pobj'] "Følge med" is usually analysed as mod. See under prepositional objects above.
  * Lønmodtagerne har mulighed for at møde**op**på generalforsamlingen. [ex. 65, should be tagged as tagged as 'part', and not `pobj' as in the sample analysis of ex. 65] "Op" in "møde op" would be analysed as avobj.
  * lægge sin stemme**om**til heltetenor [ex. 61 -- "om" should be tagged as 'part', cf. the existence of "omlægge"]**

In a limited number of cases adjectives can play the part of a particle. Here are some examples:

  * fritstille - stille frit
  * fastholde - holde fast
  * fastslå - slå fast


#### See also ####

