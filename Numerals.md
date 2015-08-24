## Numerals ##

### Numerals ###

A numeral phrase has a ''phrasal value'', which is the numerical value of the entire phrase, and a ''head value'', which is the numerical value of the head word. For example, "tre hundrede og to" has phrasal value 302, and head value 100 (assuming that "hundrede" is the head word). In our analysis, the head word in a numeral phrase is always the numeral with the largest head value -- unless the larger numeral can be analyzed as the second conjunct in a coordination, in which case the numeral that acts as first conjunct is chosen as the head. Thus, in "to og tyve" ("two and twenty" = 22), "to" is the head word, although "tyve" has larger head value.

In addition to being determiners (ie, pronouns that take an optional noun complement) when they are not governed by another numeral, numerals can also take two optional numeral complements: a ''multiplicative numeral complement'' on the immediate left (with complement edge "numm"), and an ''additive numeral complement'' on the immediate right (with complement edge "numa"). In the absence of an additive complement, the numeral may be coordinated with another numeral by means of the coordinator "og" ("and"), and the coordinator and the second conjunct are then interpreted as an additive adjunct of the head numeral. Some example analyses of numeral phrases are shown below:

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-01.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-01.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-02.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-02.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-03.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-03.png)

The phrasal value of any composite numeral phrase can be computed by multiplying the head value of the head with the phrasal value of the multiplicative complement, and then adding the phrasal value of any additive complement or adjunct. Thus, the value of "tre hundrede og to" is computed as (3) **100 + (2) = 302, and the value of "to og tyve tusind tre hundrede og to" is computed as (2 + (20))** 1000 + ((3) **100 + (2)) = 22,302.**

The numerals can be grouped into subclasses according to the requirements they place on their multiplicative and additive complements, and their second conjuncts in coordinations (some notation: if N is a numeral, we let |N|| denote its phrase value and |N| denote its head value; "**" indicates that the construction is never allowed):|
|:|**

| head numeral H | multiplicative[[BR](BR.md)]complement M | additive[[BR](BR.md)]complement A | second[[BR](BR.md)]conjunct C |
|:---------------|:----------------------------------------|:----------------------------------|:------------------------------|
| nul (0)        | | | |
| en/et to tre fire fem seks syv otte ni (1-9) | | | 20 ≤ |C| ≤ 90                 |
| ti elleve tolv tretten fjorten femten seksten sytten atten nitten (10-19) | | | |
| tyve tredive fyrre halvtres tres halvfjers firs halvfems (20-90) | | | |
| hundrede (100) | 1 ≤ |M| &lt; |H|                        | 1 ≤                               |A                              | &lt; |H|                      | 0 ≤                           |C                              | &lt; |H|                      |
| tusind (1000)  | 1 ≤ |M| &lt; |H|[[BR](BR.md)] multiplicative complement is obligatory in the presence of an additive complement | 100 ≤                             |A                              | &lt; |H|[[BR](BR.md)] any A must obligatorily have a multiplicative complement | 0 ≤                           |C                              | &lt; |H|[[BR](BR.md)] any C with |C| ≥ 100 must obligatorily have a multiplicative complement |
| million milliard billion trillion (10<sup>6</sup>/10<sup>9</sup>/10<sup>12</sup>/10<sup>18</sup>) | 1 ≤ |M| &lt; |H|[[BR](BR.md)] multiplicative complement is obligatory | 100 ≤                             |A                              | &lt; |H|[[BR](BR.md)] any A must obligatorily have a multiplicative complement | 0 ≤                           |C                              | &lt; |H|[[BR](BR.md)] any C with |C| ≥ 100 must obligatorily have a multiplicative complement |

The numerals "million", "milliard", "billion", and "trillion" have a plural inflection, which must be used whenever their multiplicative complement has head value larger than 1. All other numerals are always singular. In particular, the plural forms of "hundrede" ("hundreder") and "tusind" ("tusinde/tusinder") are analyzed as plurals of the common nouns "hundrede" and "tusind", and can not take any numeral complements or adjuncts. The numbers between 20 and 90 are partly based on a number system with base 10 ("tyve" = 2\*10, "tredive" = 3\*10, "fyrre" = 4\*10), partly based on a number system with base 20, as is evident from the old forms of these numbers ("halvtres" = "halvtresindstyve" = 2.5 **20 = 50, "tres" = "tresindstyve" = 3** 20 = 60, "halvfjers" = "halvfjersindstyve" = 3.5 **20 = 70, "firs" = "firsindstyve" = 4** 20 = 80, and "halvfems" = "halvfemsindstyve" = 4.5 **20 = 90). Syntactically, the old forms behave exactly like the new abbreviated forms, although ordinal numeral phrases can only be formed with the old forms.**

Here are some further examples of numeral phrases in Danish:

  * 1001 = et tusind og en = tusind og en = **tusind en =**et tusind et
  * 1100 = et tusind et hundrede = **tusind hundrede =**tusind et hundrede = **et tusind hundrede = elleve hundrede
  * 237,512 = to hundrede syv og tredive tusind fem hundrede og tolv
  * 2,300 = tre og tyve hundrede = to tusind tre hundrede
  * 7,001,400 = syv millioner fjorten hundrede = syv millioner et tusind fire hundrede**

A numeral can also be transformed into a common noun by adding the suffix "+er", eg.: to+er/to+er+en/to+er+e/to+er+ne.

  * tre et halvt
  * tre komma en fire en fem ...
  * tre komma fjorten femten ...
  * minus to

> Ordinal numerals:

  * nulte
  * første anden tredje fjerde femte sjette syvende ottende niende
  * tiende ellevte tolvte trettende fjortende femtende sekstende syttende attende nittende
  * tyvende tredivete fyrretyvende halvtresindstyvende tresindstyvende halvfjersindstyvende firsindstyvende halvfemsindstyvende
  * ?hundredte
  * ?tusindte
  * ?millionte ?milliardte ?billionte ?trillionte

**Are numerals pronouns or cardinal adjectives?** Numerals are usually classified as either adjectives or special nouns. While the PAROLE tagset allows both analyses, the Danish PAROLE corpus has explicitly chosen the adjectival analysis. However, Otto Jespersen writes in "Philosophy of Grammar", p. 85: "Numerals are often given as a separate part of speech; it would probably be better to treat them as a separate sub-class under the pronouns, with which they have some points in common." Jespersen argues (1) that "indefinite articles" such as "en" and "et" are best analyzed as pronouns; since they coincide with cardinal numerals in many languages, this suggests that cardinal numerals ought to be analyzed as pronouns as well; (2) that cardinal numerals can be used as pronouns, ie, on their own; and (3) that cardinal numerals are difficult to use predicatively, unlike normal adjectives.

Numerals also differ from adjectives by having no inflection for degree or definiteness, and by lacking the ability to appear in prototypical adjectival constructions like "mere X end Y" ("more X than Y"). The most frequently proposed argument for the adjectival analysis is that numerals superficially seem to appear in the same position as adjectives in examples like "de sødeste tre små elefanter", ie, between the determiner and the common noun. However, the pronominal analysis (below left) -- where "tre" is a pronoun that acts as complement of "de" and takes "elefanter" as its complement -- explains the word order just as well, so the adjectival analysis (below right) has no advantage over the pronominal analysis in this respect either.

![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-04a.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-04a.png) ![http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-04b.png](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/figs/num-04b.png)

Thus, the end result is that we have found no compelling evidence in favour of the adjectival analysis, whereas we have found many compelling reasons to analyze numerals as special pronouns -- particularly because of their ability to function as determiners, and to function as subjects and objects on their own. For these reasons, we think that numerals should be classified as a special subclass of pronouns.

**What is the syntactic structure of numeral phrases?** When comparing our analysis of numeral phrases with our analysis of noun phrases, there is a striking difference between the analysis of the numeral phrase "et hundrede" (where "et" is a complement) and the noun phrase "et hus" (where "et" is the head). For noun phrases, we have earlier argued that there are compelling reasons for selecting the determiner as the head of the noun phrase. Thus, an intuitive analogy seems to suggest that numerals should be analyzed similarly, with "et" as the head in "et hundrede". However, we have been unable to find an analysis with the first numeral as head that satisfies the most important requirement of any syntactic analysis of numeral phrases: that it should lead to an easy algorithm for finding the corresponding numerical value of the numeral phrase.

In contrast, the analysis of numerals that we have presented above does satisfy this requirement in a very natural way, and since we have been unable to find any arguments against it -- or indeed any convincing arguments why numeral phrases should be analogous to noun phrases -- we believe that our analysis of numerals is the most natural one. One alternative, which is probably viable, is to analyze "multiplicative complements" and "additive complements" as adjuncts instead, but then one has to be very careful with multiple adjuncts, the order of application of the adjuncts in the functor-argument structure, etc. In the end, we felt that the complement approach was simpler from a conceptual and computational point of view.

Another alternative, which seems perfectly viable, is to analyze the "og" plus second conjunct as a "coord"-complement instead of an adjunct. This analysis has the great advantage that the restrictions on the second conjunct can be expressed very easily, but differs from the normal analysis of coordination by analyzing the coordinator as an optional complement instead of an adjunct. Fortunately, this analysis is annotated in the same way as the ordinary coordination analysis that we have chosen, so the choice between the two analyses reduces to how one interprets the treebank annotation.


#### See also ####

