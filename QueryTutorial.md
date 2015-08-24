# Introduction #

DTAG has a sophisticated query language that can be used to search dependency graphs and alignments, extract tables, and perform automatic replace operations. The query language is based on first-order logic. This page describes the detailed syntax of the query language, provides examples of queries that can be performed with DTAG, and briefly describes how the query system works internally.



# Overview #

The most important commands are summarized below.

  * **`corpus <filespec>`**: specify the current corpus as a UNIX glob-pattern (ie, a file pattern where "`*`" matches any character).
    * `corpus ~/cdt/da/*.tag`
    * `corpus da-en/00*.atag`
  * **`find <options> <constraint> [-do(<command>)]`**: search the graph (or the entire corpus) for all occurrences that match the given constraint.
    * `find $X "subj" $Y`: find any subject $X of $Y.
    * `find ($X "subj" $Y) & ($X < $Y)`: find any preceding subject $X of $Y.
    * `find -corpus $X "subj" $Y`: search the entire corpus for subjects.
    * ``find $X isa(PRIM) $Y -do(echo $X `etypes($X isa(PRIM) $Y)` $Y\n)``: search entire corpus for primary dependencies, and print out the dependencies to screen (as they would have been entered in DTAG).
    * `find -corpus -vars($X@a,$Y@b) @($X;$Y)`: search entire corpus for alignments between two nodes $X and $Y.
  * **`next`**: goto the next match in the search (can be abbreviated as "n").
  * **`prev`**: goto the previous match in the search (can be abbreviated as "p").

# Query language syntax #

## Relation constraints ##

  * **`<node1> <relation-constraint> <node2>`**: the first node is connected to the second via an in-edge whose relation name matches the given relation constraint.

The relation constraint can be of the form:
  * **`<string>`**: an unquoted atomic relation name.
  * **`"<string>"`**: a quoted atomic relation name.
  * **`/<regexp>/`**: a [regular expression in Perl](http://perldoc.perl.org/perlre.html).
  * **`isa(<type>)`**: an isa-constraint that matches relations that match the given type specification in the relation hierarchy.

Type specifications can be of the form:
  * **`(<type>)`**: parentheses used for disambiguation.
  * **`<relation>`**: the name of a relation in the relation hierarchy.
  * **`<type1>+<type2>`**: matches both types.
  * **`<type1>|<type2>`**: matches one of the types.
  * **`-<type>`**: does not match the given type; the operator "!" can be used instead of "-".

Examples of relation constraints include:

  * `$X "subj" $Y`: find all edges into $X from $Y with atomic label "subj".
  * `$X coref $Y`: find all edges into $X from $Y with atomic label "coref".
  * `$X /obj/ $Y`: find all edges into $X from $Y whose name contains "obj".
  * `$X /^(subj|dobj)$/ $Y`: find all edges into $X from $Y whose name matches either "subj" or "dobj".
  * `$X isa(SYNADJ) $Y`: find all syntactic adjunct edges into $X from $Y.
  * `$X isa(SYN+COMP-subj) $Y`: find all edges to $X from $Y which are syntactic complement relations, except subjects.

## Adjacency constraints ##

Constraints can be placed on the adjacency or near-adjacency of nodes:

  * **`<node1> << <node2>`**: the first node immediately precedes the second.
    * `$X << $Y`
  * **`<node1> >> <node2>`**: the first node immediately succeeds the second.
  * **`<node1> <range< <node2>`**: the first node precedes the second node within the given adjacency range.
    * `$X <2< $Y`: $X is the second word before $Y.
    * `$X <2..8< $Y`: $X is 2 to 8 words before $Y.
    * `$X >1,3..5> $Y`: $X is the word after $Y, or 3 to 5 words after $Y.
  * **`<node1> >range> <node2>`**: the first node succeeds the second node within the given adjacency range.

Adjacency ranges are specified as:
  * **`<number>`**: the exact distance.
  * **`<number1>..<number2>`**: a range of distances from first to second number.
  * **`<range1>,<range2>,...`**: any comma-separated list of ranges.

## Value constraints and comparisons ##

Values can be given as atomic values (numbers or strings enclosed in double quotes), or as nodes or node features:

  * **`"<string>"`**: the given string as an atomic string value (eg '"hello world!"').
  * **`<number>`**: the given number as an atomic number value (eg '123', '-13.3').
  * **`<node>`**: the node number as a numerical value (eg, '$X').
  * **`<node>[]`**: the string associated with the node (eg, '$NODE[.md](.md)').
  * **`<node>[<attribute>]`**: the string or number associated with the given feature in the given node (eg, '`$X[msd]`'). The interpretation as string or number depends on the operator that is applied to the value.
  * **`etypes(<node1>, <node2>)`**: a string containing a space-separated list of the relation types associated with the edges to the first node from the second, in alphabetical order.
    * `etypes($X, $Y)`
  * **`etypes(<node1> <relation-constraint> <node2>)`**: a string containing a space-separated list of the relation types associated with the edges to the first node from the second, in alphabetical order. Most useful within a "-do(...)" statement.
    * `etypes($X isa(SYNCOMP) $Y)`: a list with all SYNCOMP relation names to $X from $Y.
    * ``find -yes ($X isa(COMP) $Y) -do(echo $X `etypes($X isa(COMP) $Y)` $Y\n)``: print edge specifications for all COMP-edges connecting any two nodes in the graph.

String values can be compared with the following operators:

  * **`<value1> eq <value2>`**: the two values are equal as strings, eg:
    * `$X[lemma] eq "they"`: find all nodes where the lemma attribute equals "they".
    * `$X[] eq "They"`: find all nodes where the input string equals "They".
  * **`<value1> ne <value2>`**: the two values are unequal as strings.
  * **`<value> =~ /<regexp>/`**: the string value matches the given regular expression, eg:
    * `$X[lemma] =~ /ics$/`: find all nodes where the lemma attribute ends with "ics".
  * **`<value> !~ /<regexp>/`**: the string value does not match the given regular expression.

Numerical values can be compared with the following operators:
  * **`<value1> < <value2>`**: the first value is numerically smaller than the second.
  * **`<value1> <= <value2>`**: the first value is numerically smaller than or equal to the second.
  * **`<value1> = <value2>`**: the first value is numerically equal to the second. The operator "==" can be used instead of "=".
  * **`<value1> != <value2>`**: the two values are unequal.
  * **`<value1> > <value2>`**: the first value is numerically larger than the second.
  * **`<value1> >= <value2>`**: the first value is numerically larger than or equal to the second.
For example:
  * `$X < $Y`: the first node precedes the second in the linear order.
  * `$X > $Y`: the first node succeeds the second in the linear order.
  * `$X[time] > 20.7`: the time attribute associated with $X must be at least 20.7.

## Alignment constraints ##

  * **`@(<nodes1>;<nodes2>)`**: there is an alignment edge from the first set of nodes to the second.
  * **`@<relation-constraint>(<nodes1>;<nodes2>)`**: there is an alignment edge from the first set of nodes to the second, with a relation name that matches the given relation constraint.

Node lists are specified as comma-separated lists of nodes.

## Logical constraints ##

It is advisable to enclose simple queries in parentheses "(...)" when joining them with logical operators.

  * **`! <cond>`**: satisfied if the condition fails (logical NOT). The operators "¬", "NOT", "not" can be used instead of "!".
  * **`<cond1> & <cond2>`**: satisfied by both conditions (logical AND). The operators "∧", "&&", "AND", "and" can be used instead of "&".
    * `($X subj $Y) & ($X < $Y)`: $X is a subject of $Y and located before $Y.
  * **`<cond1> | <cond2>`**: satisfied by at least one of the conditions (logical OR). The operators "∨", "||", "OR", "or" can be used instead of "|".
    * `($X subj $Y) | ($X subj $Z)`: $X is a subject of $Y or $Z.
    * `($X subj $Y) or ($X dobj $Y)`: $X is a subject or direct object of $Y (this query is much more efficiently performed as the query `$X /^(subj|dobj)$/ $Y`).
  * **`<cond1> implies <cond2>`**: satisfied by the second condition if satisfied by the first (logical IMPLIES). The operators "->", "→", "⇒", "IMPLIES" can be used instead of "implies".
    * `($X subj $Y) implies ($X < $Y)`
  * **`<cond1> if <cond2>`**: satisfied by the first condition if satisfied by the second (as IMPLIES, but reversed direction). The operators "<-", "←", "⇐", "IF" can be used instead of "if".
    * `($X < $Y) if ($X subj $Y)`
  * **`E<var>(<cond>)`**: there exists a variable instantiation of `<var>` that makes the condition true (existential quantification). The quantifiers "∃", "EXISTS", "exists" can be used instead of the quantifier "E".
    * `E$Y($Y expl $X)`: matches any node $X with an expletive subject $Y.
    * `E$Y($Y expl $X)`: as previous example, but specifies that variable $Y belongs to graph with key "a".
  * **`A<var>(<cond>)`**: the condition is satisfied for all instantiations of `<var>` (universal quantification). The quantifiers "∀", "ALL", "all" can be used instead of the quantifier "A".
    * `A$Y($Y > $X if ($Y isa(SYNADJ) $X))`: matches any node $X without preceding adjuncts.
    * `A$Y@a($Y > $X if ($Y isa(SYNADJ) $X))`: as previous example, but specifies that variable $Y belongs to graph with key "a".


# Find and replace #

DTAG provides a "-do(

&lt;command&gt;

)" option that can be used to print matches (eg, as comma-separated files), or to perform find-replace functionality. Every time a match is found, the command is executed. Before the execution, all variable names and value specifications (enclosed in backquotes `...`) are replaced with the corresponding values for the given match. Some examples are given below.

The following command can be used to find all complement edges and print them as DTAG edge specifications:

> ``find -yes $X isa(COMP) $Y -do(echo $X `etypes($X isa(COMP) $Y)` $Y\n)``: find all complement edges and print them as the corresponding DTAG specification.

The following command can be used to find all "subj" edges and replace the edge label with "SUBJ":

> `find -yes $X "subj" $Y -do(edel $X subj $Y ; $X SUBJ $Y)`

The following command replaces all edges of type COMP with "MYCOMP" edges:

> ``find -yes $X isa(COMP) $Y -do(edel $X `etypes($X isa(COMP) $Y)` ; $X MYCOMP $Y)``


  * `tell@MYTABLE /tmp/mytable.csv`
> > ``find $X isa(COMP) $Y -do(echo@MYTABLE $X `etypes($X isa(COMP) $Y)` $Y\n)``
> > }}}: find all   **{{{f**

# Options #

# Example queries #