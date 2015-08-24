## Search ##

A graph search is specified as a constraint satisfaction problem where we must find all possible variable instantiations that make those variables satisfy a given constraint. The constraint is a term composed of simple constraints connected by the logical operators "&amp;" or "," (and), "|" (or), and "!" (negation). Parentheses can be inserted to disambiguate operator arguments.

Possible constraints:

  * **$node1 &lt; $node2**: node $node1 must precede node $node2.
  * **$node1 &gt; $node2**: node $node1 must succede node $node2.
  * **$node1 != $node2**: node $node1 must not coincide with node $node2.
  * **$node1 == $node2**: node $node1 must coincide with node $node2.
  * **$node:$type**: node $node must have super type $type in the type hierarchy.
  * **$node[$var] =~ $regexp**: variable $var in node $node must match regular expression $regexp.
  * **$node1 $espec $node2**: node $node1 must be a dependent of node $node2 with edge type satisfying edge specification $espec.
  * **$node1 path($path) $node2**: node $node1 must have a path to $node2 matching path specification $path; a path specification has the form:
    * ''path'' ::= ''spath'' | ''spath'' ''path''
    * ''spath'' ::= **&lt;** ''etype'' | **&gt;** ''etype'' | **{** ''spath'' **}+**  where `&lt;''etype''` denotes an downwards edge (to a dependent) of type ''etype'', and `&gt;''etype''` denotes an upwards edge (to a governor) of type ''etype''.
  * **sort($level, $expr):** always true; has the side-effect of using expression $expr as sorting key at level $level; $expr must specify a variable of one of the words, using the notation "$node-&gt;$var".

### Examples of search queries ###

  * ''find graph with an expletive before its main verb:''` $1 expl $2,[[BR]] $1:word,[[BR]] $2:verb,[[BR]] $1&lt;$2 `
  * ''find graph with a topicalized non-subject'': ` $1 land-subj $2,[[BR]] $1:noun-vmod,[[BR]] $2:verb,[[BR]] $1&lt;$2 `
  * ''find a relativized object:'': ` $3 rel $1,[[BR]] $2 ref $1,[[BR]] $2 path({&gt;dep}+) $3,[[BR]] $1:noun+[obj],[[BR]] $2:word,[[BR]] $3:verb,[[BR]] $1&lt;$2,[[BR]] $2&lt;$3 `


#### See also ####

