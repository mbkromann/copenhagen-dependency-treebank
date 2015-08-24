## Relatives ##

Relative clauses that modify a clause are analyzed as adjuncts of the finite verb. For these we use the special adjunct edge rel, which is also used for relative clauses that modify nominals.

  * Jeg har lavet kage, **som du bad mig om**.
  * De har restaureret kirken, **hvilket har pyntet en hel del**.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png)

Relatives are constructions where a clause (called the ''relative clause'') attaches itself as a "rel"-adjunct to its governor (ie, the ''relativized phrase''). The relativized phrase must satisfy a secondary role within the relativized clause, either by having a secondary filler dependency to some governor within the relative clause, or by being the antecedent of some relative or interrogative pronoun within the first phrase in the relative clause. The verb in the relative clause must either have V2 word order, or V3 verb order where the first

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-03.png)

Relatives can be quite confusing, when there is more than one and it is combined with it-clefts and and expletives:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-18.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-18.png)

The relative pronoun is analyzed as a dependent of some head inside the relative clause. In the case of subject and object relatives, the governor is a verb. In other cases the relative pronoun is a dependent of a preposition:

  * kvinden **til hvem han sendte brevet**
  * ham **på hvem vi ser**
  * ham **som vi ser på**
  * det tidspunkt **på hvilket han mente vi var skøre**

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-05.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-14.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-14.png)

Note that whether the preposition is pied-piped with the relative pronoun to the front of the clause or not makes no difference for the dependency structure (without pied-piping we simply have a discontinuous PP). It does make a difference for the choice of relative pronoun: "hv"-pronoun for pied-piping and "som" when the preposition is not pied-piped. This correlation is captured in the lexicon.

The relative pronoun is anaphorically dependent on the element that the relative clause modifies, which we indicate with a secondary dependency edge labelled ref.

The relative pronoun may itself have dependents, as in the case of the genitive relative pronoun "hvis":

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-08.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-08.png)

Some terminology: ''relativized word'' = word that has been extracted from below the relative verb; ''relative verb'' = verb that heads the relative clause; ''relativizer'' = optional relative pronoun or prepositional phrase with embedded relative pronoun.

In relative clauses without a relative pronoun, the function of the modified element with respect to the internal syntax of the relative clause is indicated via a filler dependency:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-13.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-13.png)

Relative clauses that modify a clause are analyzed as adjuncts of the finite verb. For these we use the special adjunct edge rel, which is also used for relative clauses that modify nominals.

  * Jeg har lavet kage, **som du bad mig om**.
  * De har restaureret kirken, **hvilket har pyntet en hel del**.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png)

The relative pronoun does not always pick up the reference from the last phrase of the relativized sentence. Especially in constructions with "det + være + pred", the relativized phrase is "det", if "det" does not refer to something previously mentioned.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine17.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine17.png)

> A reconstruction reveals the correct analysis:

  * **Den dygtigste, der vinder prisen, er det"
  * Det, der vinder prisen, er den dygtigste**

**Free relatives / embedded wh-questions.** Free relatives are relatives where the relativized phrase is a wh-phrase. Some examples are shown below:

  * De spurgte **hvem der stjal kagerne**.
  * Han spiste **hvad de havde**.
  * Gør **hvad du vil**. (PFGA, p. 156)
  * Jeg brød mig ikke om **hvad jeg så**. (PFGA, p. 156)
  * Han vidste **hvornår jeg ankom**.
  * Han spurgte **hvad de manglede**.
  * **Hvem de valgte**, er ikke afgørende.
  * Debatten handlede om **hvorvidt stavepladen var fup**.
  * **Hvor der ikke er mødepligt**, vil der være opgaver.

These examples are analyzed just like normal relative clauses:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/interrogative-10.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/interrogative-10.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-16.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-16.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/interrogative-09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/interrogative-09.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-17.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-17.png)

Wh-relatives differ from normal relatives by not allowing the relative pronoun "som" for objects and subjects, but otherwise they have the same properties, including the obligatory use of the relative pronoun "der" in subject relatives and the optionality of the relative clause, as in:

  * Hvem der derimod kom ind i stuen, det var Marie.
  * Denn wem die Magie einer solchen Stunde nie bewußt geworden, wird ebenso wenig verstehen.
  * "Nogen ødelagde en rude -- jeg ved ikke hvem" / "Somebody broke a window -- I don't know who").
  * Hvor dygtig han end er, så får han ikke stillingen.
  * Hvor gode hans kvalifikationer end er, (så) får han ikke stillingen.

In the "hvor + AN"-constructions it is difficult whether to consider "hvor" a modifier of the adjective or to consider "hvor" as the head of the relative clause. We have decided to follow the "hvor"-as-modifier-analysis:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine03.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine04.png)

> An alternative would be to follow the intuition that "hvor" must be the head of the relative clause. Such an analysis would look like this:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine05.png)

> The problem with this analysis is, that it conflicts with the understanding of "hvor" as a modifier to "svært" and of "svært" being the head of the predicative frase. We would not like to say that "hvor" is the [pred](pred.md) of "være", and the consequence is that the analysis points out to heads of the frase "hvor svært".

In German (PJ, "Tysk Grammatik"):

  * Es gab Wirtshäuser, die zu betreten den Studenten verboten war. (Böll)
  * Der junge Beisem, dem die Regeln der Bruchrechnung beizubringen ich mich verpflichtet hat. (Böll)
  * Ich weiß nur ein Gesicht, dessen veredelte Wirklichkeit durch mein Einbildungskraft korrigieren zu wollen sündhaft wäre. (Mann)
  * Die den Sinn des Martyrium leugneten, [die](die.md) gerieten am leichtesten in Verfolgung und Folter.
  * Du zahlst jetzt [das](das.md), was du getrunken hast.
  * Wem Gott Kinder gibt, dem gibt er auch sorgen.

Han spurgte hvem der kom" and "Han spurgte hvem. A class of more problematic examples are listed below:

  * Vi opdagede **til hvem han sendte brevene**.
  * Han redegjorde for **på hvilket tidspunkt og under hvilke omstændigheder han købte maleriet**.
  * Han redegjorde for **på hvilket tidspunkt han købte maleriet ?(og) under hvilke omstændigheder**.
  * Spørgsmålet om **hvor stor (en) andel af forskningsmidlerne forskerne frit kan råde over**.

  * Han gav noget til nogen. Jeg ved ikke **hvem/hvad/hvor/hvorfor/hvordan/hvornår/med hvem/til hvem/af hvilken årsag/på hvilket grundlag**.
  * Jeg kan ikke forklare **hvor/hvorfor/hvordan/hvornår/med hvem/til hvem**.
  * Han gav kuverten til nogen. Jeg så ikke **til hvem**.
  * Vi havde uforholdsmæssigt mange røverier , uden at jeg kan forklare **hvorfor**.

  * Det er derfor at han siger det.
  * Hvorfor det er han siger det.
  * hvorfor det er at han siger den slags.

These are sometimes called head-less relative clause (with reference to the fact that they do not modify an external head), but we prefer the term 'independent relative clause', since, on our analysis, they do have a head, namely the relative pronoun. What is special about this construction is that the relative clause functions as a complement in its own right, and not as a modifier of a complement. This is reflected in our analysis by having the relative pronoun function as a complement to the external governor:

Independent relatives have the same form as embedded interrogatives, but the two can be distinguished by their semantics, as reflected by the subcategorization properties of their governor:

  * Han spiste {**hvad de havde**} [relative](independent.md)
  * Han spurgte {**hvad de havde**/**den} [interrogative](embedded.md)**

**Embedded interrogatives.** Interrogatives can occur as dependents to an external governor. Embedded wh-interrogatives are analyzed like relative clauses.

**VPs and APs as relativized phrases.** Relative clause typically modify nouns, but (non-restrictive) relative clauses can also modify a verb or adjective:

  * Jeg har lavet kage, som du bad mig om.
  * Huset er grønt, hvilket er en dejlig farve.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png)

**Reduced relatives.**

  * vin **købt specielt til lejligheden** (cf. vin **som er** købt specielt til lejligheden)
  * huer **strikket i ren uld** (cf. huer **som er** strikket i ren uld)
  * en maskine **konstrueret efter særlige principper** (cf. en maskine **som er** konstrueret efter særlige principper)

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/mod-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/mod-01.png)

> German data (judgements by Sabine Kirchmeier-Andersen):

  * Wer/**wen die Schüler verachtet, is ein schlechter Lehrer.
  * Wen/**wer die Schüler verachten, ist ein schlechter Lehrer.
  * Ich verachte wer/**wen die Schüler haßt.
  * Ich verachte wen/**wer die Schüler hassen.
  * Ich frage wer/**wen die Schüler verachtet.
  * Ich frage wen/**wer die Schüler verachten.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/interrogative-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/interrogative-04.png)

> An alternative is to extend the analysis of [independent relatives](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/#____id_rel) to embedded interrogatives. Under this analysis the "wh"-word is the head of the construction which takes the finite verb as a rel dependent. Arguments in favor of the relative clause analysis:

  * The fact that the two constructions display the same word order follows naturally.
  * The tagger need not distinguish the two constructions in the treebank.
  * It provides a natural explanation for the occurrence of "der" in embedded subject interrogatives, an otherwise puzzling fact (Diderichsen 1957: 183): "Han spurgte hvem **der** kom."

> Arguments against the relative clause analysis:

  * It yields a non-uniform analysis of embedded and matrix "wh"-interrogatives.
  * In matrix interrogatives the finite verb is the head, and the "wh"-word is its dependent
  * In embedded interrogatives, the "wh"-word is the head and the finite verb is its dependent.
  * The interpretive difference between independent relatives and embedded interrogatives is not reflected in the syntactic analysis.

> Arguments in favor of the interrogative analysis:

  * It provides a uniform analysis of embedded and matrix interrogatives.
  * It follows the tradition.
  * It accomodates the semantics of this construction

> Arguments against the interrogative analysis: It provides no obvious account of the presence of "der" in embedded subject interrogatives. Several analyses are possible, but none of them are without problems.

  * "der" is an expletive subject, "hvem" is a dobj (compare: der kom en mand). **advantages**: uses existing analysis (of expletive constructions). **problems**: the use of "der" in embedded subject interrogatives is less restricted than ordinary expletive constructions (han spurgte hvem der havde taget af kagen -- **der havde taget en mand af kagen)
  * "der" is a modifier to the finite embedded verb (I believe this is the analysis proposed in diderichsen (1957:183) where it is stated that in this use "der" is 'clearly an adverbial and not a subject pronoun'.**advantages:**no comparison with expletive constructions.**problems**: ad hoc, such modifiers are not allowed elsewhere
  * "der" is a modifier to "hvem".**advantages**: no comparison with expletive constructions.**problems**: ad hoc, such modifiers are not allowed elsewhere.
  * "der" is a modifier to the embedding verb.**advantages**: no comparison with expletive constructions.**problems**: ad hoc, such modifiers are not allowed elsewhere**

**What the other treebanks do.** Corpus Gespokenes Nederlands (CGN Syntactische Annotatie pp. 47-48))) distinguishes independent relatives (`hoofdloze relatiefzinnen') from embedded interrogatives (`afhankelijke vraagzinnen'), and give some tests for how to distinguish them in the corpus (e.g. whether one can insert a personal pronoun in front of the relative pronoun - if yes, it is a relative clause, if no, it is an embedded interrogative.)

Penn Treebank (1995 Bracketing Guidelines pp. 169-170)) also distinguishes independent relatives ('head-less relatives' in their terminology) from embedded interrogatives ('indirect questions' in their terminology). They give semantic criteria for distinguishing the two.

In the DG analysis, we always assume that the relativizing phrase lands on the relativized phrase with a "relz" landing edge. This is not shown in the treebank analyses, but corresponds to the following graphs:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-01dg.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-01dg.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-05dg.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-05dg.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09dg.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09dg.png)

Hudson analyzes relative pronouns as heads of the relative clause, which allows him to avoid the use of anaphoric references (he does not deal with relative prepositional phrases, eg, "til hvem") and give a more uniform account of relative clauses with and without relative pronouns. This analyzes may have great advantages during parsing as well, because the relative pronoun can be attached right away.

Another (perhaps even more attractive) analysis is to: (1) in subject relatives, the relative pronoun lands on the relative verb and has the relativized word as its antecedent, giving V2 order in the verb; (2) in relatives with any other relative phrase, the relative phrase lands on the relativized word and has the relativized word as its antecedent, giving V2 order in the relative verb; (3) in all other relatives (ie, those without a relative phrase), the relative verb creates a filler node that has the relativized word as its antecedent, also resulting in V2 order.

> Post-nominal modifiers headed by a perfect participle could be analyzed as reduced subject relative clauses:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-15.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-15.png)

Alternatively, this construction can be analyzed as a regular mod adjunct, headed by the perfect participle. The internal structure of the modifier is the same under this analysis. The only difference is that `mod' replaces `rel'.

As discussed in Gerhard Helbig, "Studien zur deutschen Syntax", the traditional distinction between relatives, embedded wh-questions, and clauses headed by a complementizer is somewhat ad-hoc, since it defines the three classes in terms of mutually inconsistent morphological, syntactic, semantic and pragmatic criteria, and many examples are extremely hard to classify in a consistent way.

#### Prepositional phrase as relativized phrase ####

Usually the relativized phrase is a nominal phrase of some kind or a sentence, that is, the relativized phrase is a verbal phrase. In a few cases the relativized phrase can be a prepositional phrase - a phrase headed by a preposition. This preposition then is the governor of the relative clause.

In the corpus we have only come across a few examples, 9 examples of the following 6 expressions:

  * i den udstrækning
  * i det omfang
  * i hvilket omfang
  * i hvilken grad
  * i hvilken kategori
  * for hvem

> Examples of analysis follow below:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine89a.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine89a.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine89b.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine89b.png)

#### "Ligesom" and "som" ####

"Ligesom" and "som" (meaning "ligesom") often marks a relative construction, but not always. To determine whether the construction is in fact a relative clause, we have used the following criteria:

  * If the sentence is not complete on its own, the construction is analysed as a relative clause with a filler dependency.
  * If the sentence is complete on its own, the construction is analysed as a non-relative construction, that attaches itself to its governor as a verbal object (vobj).

> Here are some examples of the different analyses:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png)

> Here "som" could be replaced by "ligesom". If we do not analyse this as a relative clause, the analysis would look like this:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine87.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine87.png)

> Here "bede om" obviously lacks an object, and this indicates, that the relative-analysis is correct. Here is another example:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine88.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine88.png)

> This is an analysis parallel to the non-relative analysis above, but with this example there is no part missing; the sentence is complete. A relative analysis would therefore be wrong here.

#### Subordinate conjunctions ####

Some subordinate conjunctions (CS) (dengang, før, da, siden, hvis, når, fordi, end) sometimes have some marks of a relative clause: The sentence they take seems to be missing that something, that the CS represents. This indicates that these constructions should be analysed as relatives. On the other hand, another guideline we have followed in determining whether a construction should be analysed as a relative or not, is whether the CS most likely would be able to take a "som" - making it a relative - or an "at" - making it a vobj. And all of the subordinate conjunctions mentioned above most likely would take an "at", which indicates that an analysis that sees them as taking a relative would be wrong.

These to tests for whether it is a relative or not, point in two directions. We have decided to go with the vobj-analysis, since the fact that they cannot take the relative pronoun "som" indicates that they are not truly relatives. This on the other hand leaves us with an unsolved problem, namely that these sentences often miss an otherwise obligatory part (direct object, nominal object or even subject).

#### The adverbial "så længe" ####

Regarding the adverbial "så længe", we believe that the correct analysis is that "så længe" takes a sentence as a relative. This is because this phrase actually tends to be able to take the relative pronoun "som" (e.g. "Jeg sover lige så længe, som jeg har lyst til"). Here is an axample of the analysis:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/stine09.png)


#### See also ####

