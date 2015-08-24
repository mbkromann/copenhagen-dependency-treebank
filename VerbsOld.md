==  Verbs Old ==

**Subject** The dependency label subj is used for the subject of a finite (tensed?) verb. The subject can be a nominal, an infinitive construction headed by "at", or a finite clause headed by "at":

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/inf-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/inf-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/subject-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/subject-02.png)

Verbal complements of a modal or auxiliary verb share the subject via a [subj](subj.md) filler:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/inf-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/inf-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/subject-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/subject-01.png)

**Expletive subject** Any verb that does not have a direct object can undergo expletive shift -- that is, the subject is converted into a direct object, with the additional restriction that it must be indefinite, and a locative or temporal adverbial (usually "der") becomes a formal subject (expl) (an observation due to Richard Hudson). This provides a method for determining whether the object in a verb with a single object is a direct or indirect object.

  * Der mangler en gaffel.
  * Her tales om et klokkeklart mord.
  * Der er tilfaldet den ældste datter en stor pengesum.
  * I en drøm vil åbenbares Guds formål med dig, Johannes.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-05.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-03.png)

Complements of the finite verb share the expletive subject via a [expl](expl.md) filler.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-02.png)

**Direct object** We use the dependency label dobj for the direct object of a verb, including the single, non-subject, nominal complement of transitive verbs, the theme argument of ditransitive verbs, and the accusative object of accusative-with-infinite constructions:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-03.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/dobj-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/dobj-01.png)

Note that dobj is also used for complements headed by "at", consistent with our analysis of "at" as a pronoun that takes a verbal complement. The lexical entry of the governing verb specifices that its dobj must be headed by "at". [RAISING AND CONTROL](SEE.md)

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/dobj-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/dobj-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/dobj-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/dobj-03.png)

**Indirect object** We use iobj for indirect objects of ditransitive verbs. This argument expresses the beneficiary or recipient.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-03.png)

Note that when this argument is expressed with a preposition ("Han viste den til hende") it is tagged as a prepositional object, and not an indirect object (jvf. ex 31).

**Prepositional object\*We use pobj for complements headed by a preposition. Some prepositional complement express a (physical) location or direction, others express more abstract relations. In the latter case the verb typically subcategorizes for a specific preposition.**

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/val-04.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pobj-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pobj-01.png)

It is important to distinguish prepositional complements from prepositional modifiers:

  * Han ventede **på dem** (pobj)
  * Han ventede **på stationen** (mod)

**Verbal complement** The label vobj is used for (non-finite only?) verbal complements. Bare infinitives occur as verbal complements of modal verb and verbs of perception and permission:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/inf-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/inf-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/vobj-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/vobj-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/dobj-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/dobj-01.png)

Past participles occur as vobj of auxiliary verbs, including the passive auxiliary "blive".

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/subject-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/subject-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/vobj-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/vobj-02.png)

**Predicative complement** The dependecy label pred is used for predicative complements. Semantically, these can be oriented towards the subject or the object. Subject-oriented predicative complements occur with copula verbs like "være", "synes", "blive":

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-04.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-05.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-10.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-10.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pred-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pred-03.png)

As the examples show, a predicative complement can be (headed by) an adjective, noun, preposition, or adverb. [ABOUT VERBAL FORMS LIKE 'DOMINERENDE' IN 'HAN ER DOMINERENDE'?](WHAT.md)

Note that unmodified nominal complements that describe the subjects profession, education, or role appear without a determiner:

  * Hun er {læge/datalog/formand}.

Object-oriented predicative complements are found in resultative constructions:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pred-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pred-01.png)

[Q: ARE THERE SUBJECT-ORIENTED RESULTATIVES?]

and as the predicative complement of a verb like "finde":

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pred-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/pred-02.png)

**Particle** We use the label part for verbal particles. These are (always?) separable prefixes, which elsewhere occur together with the verb in a complex word form:

  * Hun gav op. [cf. Hun opgav]
  * Han meldte sig til [cf. Han tilmeldte sig]

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/particle-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/particle-01.png)

  * De gik sagen igennem [gennemgik sagen](de.md)
  * De spiste med
  * Han hørte efter

### Verb forms and verbal complements ###

#### Infinitives ####

Infinitives occur as verbal complements to "to", which we analyze as a pronoun. "to" + infinitive occurs as subject of a verb:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/inf-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/inf-02.png)

as a nominal complement in raising structures:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/raising-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/raising-01.png)

and as a nominal complement in control structures:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-3.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-3.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-4.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-4.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-5.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-5.png)

Some control verbs take a bare infinitival complement (without "at"):

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-1.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-1.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-2.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/control-2.png)

[QUESTION: DO THE SUBJECT FILLERS HAVE SYNTACTIC REALITY?]

  * lade børnene svømme vil han ikke
  * svømme vil han ikke lade børnene
  * **børnene svømme vil han ikke lade
  * svømme vil han ikke lade børnene gøre selv
  * at svømme vil han ikke lade børnene gøre selv
  ***han vil ikke lade børnene gøre at svømme selv
  * **han vil ikke lade børnene gøre svømme selv
  ***han vil ikke lade børnene at svømme selv
  * drikke vin kan han ikke lide at lade sine venner gøre uden ham

#### Perfect participle ####

  * løsladt efter vold
  * tidligere dømt for vold

#### Present participle ####

#### Gerunds ####

  * Norma's complaining about everyone never fails to annoy me (EDT)

#### Imperatives ####

In imperatives, the subject is always absent and always refers to the intended listener (thus, a vocative within an infinitive always coincides with the subject, but only by coreference, the subject role is not actually present).

  * Du, slå nu ikke din lillesøster.
  * Slå nu ikke din lillesøster, du.
  * ?Slå du nu ikke din lillesøster.
  * Giv nu jer selv lidt mere tid.

### Vocatives ###

Vocatives are characterized by being either:

  * **pronouns (2nd person):** du, I
  * **definite adjectives (pos./superlative):** (du/I/min) elskede, søde, gamle, sødeste
  * **indefinite noun:** dreng, gamle mand, far, smed, hest, brumlebi

The vocative must be placed either at the beginning or the end of the sentence. A vocative can also be placed in the right field of a verbal phrase before any nominal or prepositional objects, and before any adverbials, but possibly before verbal objects and "at"-infinitives. Examples:

  * Marie, luk så den dør!
  * Luk så den dør, Marie!
  * Marie, vil du/I godt lukke den dør?
  * ?Vil du/I, Marie, godt lukke den dør?
  * Vil du/I godt lukke den dør, Marie?
  * Marie, jeg lukker døren nu.
  * Jeg lukker døren nu, Marie.
  * Vil du [Marie](Marie.md) være så venlig [Marie](Marie.md) at lukke den dør nu [Marie](Marie.md)?
  * Far/søde/elskede/min søde, vil du komme med kaffen?
  * Vil du komme med kaffen, far/søde/elskede/min søde?
  * Mænd/**drengene/fremmede
  * Broder/gamle mand/kammerat, hent lige avisen.
  ***Jeg/**mig/du der/**ham-hende-den-der/**vi/I drenge/jer drenge/dem luk så den dør.
  * Luk nu den dør, du/I der/I.
  * Luk nu, drenge, den dør!
  * Kom nu herhen, hest!**

### External topics?? ###

External topics are sentence-initial phrases that are duplicated by a pronoun within the sentence. If the main sentence is V2 ("declarative"), then there is a strong preference for the resumptive pronoun to immediately succeed the external topic by topicalization. If the main sentence is V1 ("interrogative"), then normal word order is preserved, and the resumptive pronoun does not have to immediately succeed the external topic.

  * Marie, hun er da lidt underlig idag.
  * Marie, er hun ikke lidt underlig idag.
  * Marie, hende har jeg ikke set meget til på det seneste.
  * ??Marie, jeg har ikke set meget til hende på det seneste.
  * Og børnene, har du hørt noget til dem for nylig?
  * ??Og børnene, du har vel ikke hørt meget til dem for nylig?
  * Grøn, det er nu ikke nogen pæn farve.
  * Grøn, synes du virkelig det er en pæn farve?
  * Skrive opgave i dag, det kan jeg ikke forestille mig at han vil.
  * Skrive opgave, tror du han vil det?
  * Når han er sulten, så spiser han altid for meget.

### Wh-questions ###

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-06.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-06.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-07.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-07.png)

### Relatives ###

Subject relatives:

  * den dreng der løber
  * drengen der løber
  * drengen som løber

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-04.png)

Object relatives:

  * barnet som vi mader
  * barnet vi mader

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-03.png)

Other relatives that modify nouns:

  * kvinden til hvem han sendte brevet
  * barnet hvis mad vi anretter
  * barnet til hvem vi giver maden
  * manden efter hvis mening vi var skøre
  * det tidspunkt på hvilket han mente vi var skøre

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-05.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-08.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-08.png)

VP-relativer:

  * Jeg har lavet kage, som du bad mig om.
  * Som du bad mig om, har jeg luftet hunden.
  * Ham, som vi har vidst længe, kendte hun ikke.
  * Ham, som vi har kendt længe, hørte hun ikke.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-09.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-10.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-10.png)

Reduced relative clauses:

  * the flight chosen by you (EDT)

Discontinuous relatives:

  * Vi har med en gruppe unge at gøre som hele døgnet er omgivet af forældre og kammerater (TV-avisen, 5.6. 2002)

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-12.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/rel-12.png)

### Expletives ###

Any verb in Danish that does not have a direct object can undergo expletive shift -- that is, the subject is converted into a direct object, with the additional restriction that it must be indefinite, and a locative or temporal adverbial (usually "der") becomes a formal subject (an observation due to Richard Hudson). (Incidentally, this provides a method for determining whether the object in a verb with a single object is a direct or indirect object.)

The expletive subject is labeled "expl" in the graph, also for any intervening auxiliary or modal verbs. Some examples of expletives are shown below:

  * Der er tilfaldet den ældste datter en stor pengesum.
  * I en drøm vil åbenbares Guds formål med dig, Johannes.
  * Her/der er tale om et klokkeklart mord.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-03.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/expl-02.png)

### Passives ###

Almost all verbs in Danish have a passive infinitive, present, past and past participle form. The passivization converts the subject into an "af"-complement of the verb, and converts either a direct object, and indirect object, or the nominal object of a prepositional object into a new subject.

  * X giver Y Z =&gt;
    * Y gives Z af X
    * Z gives Y af X
  * X giver Z til Y =&gt;
    * Z gives til Y af X
    * Y gives Z til af X
    * til Y gives Z af X
  * Marie bliver set på af Søren.
  * **Marie ses på af Søren.
  * Vejen bliver løbet på af Søren.
  * ??Vejen løbes på af Søren.
  * ??Huset bliver talt i af Marie.
  ***Huset tales i af Marie.

### VP ellipsis ###

  * Bage kage vil han ikke lade børnene gøre selv.

### Other phenomena ###

A main clause may be modified by another following main clause.

  * Stolen er da smuk, er den ikke?
  * Stolen er smuk, ja.
  * Stolen er smuk, ja den er.
  * Stolen er da smuk. Er den ikke?

Hypothetical statements and conditionals:

  * Vandt jeg bare i Lotto i morgen, kunne jeg købe et nyt hus.
  * Vinder jeg i Lotto i morgen, kan jeg købe et nyt hus.
  * Havde han ikke været så uforsigtig, var det aldrig gået så galt.

### Copula constructions ###

The copula verb "være" occurs in several different syntactic contexts. We assume the following three valency frames:

1. "være" takes a subject and a perfective, unaccusative, verbal complement:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-01.png)

2. "være" takes a subject and a predicate complement, which can be an adjective, noun, preposition or adverbial:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-03.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-04.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-04.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-05.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-05.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-06.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-06.png)

3. "være" takes an expletive subject and a nominal complement, which is typically indefinite (see section on expletive constructions):

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-07.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-07.png)

Clefts are analysed as instances of the second valency frame, where the relative clause is an extraposed dependent of the subject:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-08.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-08.png)

The same dependency structure is found without extraposition in:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-09.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/copula-09.png)



#### See also ####

