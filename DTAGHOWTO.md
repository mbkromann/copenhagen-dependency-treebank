== DTAG HOWTO ==

This document describes how to use DTAG for different tasks. See our [working paper](http://copenhagen-dependency-treebank.googlecode.com/svn/trunk/docs/2010-wp-dtag.pdf) for an overview of DTAG, and [DTAG installation HOWTO](DTAGINSTALL.md) for how to install DTAG.



### Starting and closing DTAG ###

Start DTAG by clicking on the "DTAG" icon on your desktop.

> CBS only: If you are  connected to the Internet, you should update DTAG first by
> clicking on the "Update DTAG" icon. You may have to enter your username and password
> before you get a network connection: open a browser by clicking on the Firefox icon
> at the top menu bar, open an arbitrary internet page, and enter your CBS username and
> password when prompted. You can choose wireless LAN by clicking on the Network
> icon at the top menu bar on the right.

  * **`viewer`**: show the current graph in a window (if the viewer doesn't display correctly, simply restart the viewer by closing the viewer window and typing `viewer` again.
  * **`cdtmanual`**: open the CDT manual with the inventory of linguistic relations used in the Copenhagen Dependency Treebanks, agreement scores and status.
  * **`note <node> <text>`**: make a note at the given node with the given text (used if you want to comment on a certain part of the graph, eg, for later post-editing).
  * **`notes`**: print all notes associated with nodes in the visible text.
  * **`edges <node>`**: show all alignment edges or incoming edges at the given node. The command can be abbreviated **`<node>`**, and in an alignment graph, the node key is assumed to be "a" unless otherwise stated. Eg, in an alignment graph, the following three commands are equivalent: `edges a12`, `a12`, `12`.
  * **command line:** you can use up- and down-arrows to see previous commands, left- and right-arrows to edit previous commands; hit return to re-execute the command.

### Annotating dependency graphs ###

  * **`<node> <label> <node>`**: create a dependency edge stating that the first node is a `label` dependent of the second node (eg, `23 subj 45`). The dependency is drawn as an arrow that starts at the governor (head word) and ends at the dependent (subordinate word).
  * **`edel <node>`**: delete all in-coming edges at the given node.
  * **`edel <node> <label> <node>`**: delete the given dependency edge.
  * **`show <node>`**: display the graph starting from the given node. Uses relative node numbering (+-=), as in offset. Eg: `show 30`, `show -30`, `show =0` (show entire graph).
  * **`oshow <offset>`**: display the graph from the given node, renumbering it as node 0. Eg: `oshow 30`, `oshow -30`, `oshow =0` (show entire graph).
  * **`text`**: print the entire graph as plain text with node numbering; use **`textn`** if you want a more detailed numbering.
  * **`discourse`**: display the graph with a color scheme suitable for discourse annotation.
  * **`syntax`**: display the graph with a color scheme suitable for syntax annotation.
  * **`morphology`**:display the graph with the morphological annotations below the node.
  * **`noerrors`**: turn off all coloring of errors etc. to produce a nice black-white image of the graph.

It is possible to create your own dependency graphs within DTAG, for example eg, for small examples.

  * **`vars <variable>:<abbreviation>`**: specify the permitted node features. Eg: `vars cat:c gloss:g` defines the node variable `cat` with abbreviation `c`, and the variable `gloss` with abbreviation `g`; `vars cat gloss` defines the variables without abbreviations; and `vars` without arguments prints the currently defined variables.
  * **`node <position> <word> <variable>=<value>...`**: insert a new node in the graph for the given word at the given position, setting the specified node variables. Eg: `node 3 Mann g="man" c="N"` inserts a node for "Mann" at position 3, and `node Mann` inserts a node for "Mann" as the final node in the graph. As a brief-hand, you can use a single space instead of typing "node". Eg: `" Mann"` is equivalent to `"node Mann"`.
  * **`edit <position> <variable>=<value>...`**: edit the node features at the given node. Eg: `edit 3 g="man" c="N"` sets the "g" feature to "man", etc., and `edit 3` edits all features of node 3.
  * **`move <position1> <position2>`**: reorder the nodes in the graph by moving the node at the first position to the second position.

DTAG allows the set of permitted relations to be encoded as a spreadsheet (csv file). This spreadsheet defines each of the relations in the set of permitted relations, and its relationship to other relations.

  * **`relset <name> <url>`**: specifies that the relation set with the given name is defined at the csv-file at the given url. Eg: `relset` shows the current relation set. `relset <name>` sets the current relation set. `relset cdt http://spreadsheets.google.com/pub?key=rsTXbk_yYNLCst1bijZTWCQ&output=csv` defines the standard CDT relation set.
  * **`?<relation>`**: print help and examples for the given relation. Eg: `?subj`
  * **`??<regexp>`**: print all relations whose help matches the given string or regular expression. Eg: `??predicative` prints all relations where the help file contains the word predicative.


### Example format ###

DTAG supports a very condensed example format. In this format, the graph is specified by a sequence of space-separated node specifications. Eg:

> `They<2:subj,3:[subj]> did help<2:vobj> us<3:iobj> .<2:pnct>`

> `They|N<2:subj,3:[subj]> did|V help|V<2:vobj> us|N<3:iobj> .|Pnct<2:pnct>`

Each node consists of a node specification followed by an optional edge specification in angled brackets. The node specification consists of a word followed by an arbitrary number of features separated by a vertical bar. The edge specification consists of a comma-separated list of `<position>:<label>` pairs. The position is specified absolutely, with the first word at position 1.

  * **`example [-add] [-title=<title>] <specification>`**: create a graph from the given example specification. The graph title is optional and can be used to specify glosses. The option `-add` ensures that the example is added to the bottom of the current graph, otherwise the example is created as a new graph. Eg: `example -add -title="Here it is" Her|Here<2:expl> er|is den|it<2:preds>`
  * **`as.example [<node-variables>] [<range>]`**: prints a graph as an example string. The optional node variables are given as a list of node variable names separated by vertical bars "|". The optional range specification is given as a space-separated list of node numbers ("n") or node ranges ("n1..n2"); nodes can be given either as absolute node positions (prefixed by "=") or as relative node positions (prefixed by "-", "+", or nothing). Eg: `as.example cat|gloss -1 3..5 7..12 =27`
  * **`nocolors`**: remove all colors (e.g. red or green) from the graph.
  * **`nonumbers`**: remove all numbers below the graph.
  * **`etypes -add -$category $types`**: manually specify a list of edge types that DTAG should recognize as valid. $types is a space-separated list of edge type names. $category can be any category name; predefined names include "comp" (complements), "adj" (adjuncts), and "ref" (coreference relations). The optional `-add` specifies that the edge types are added to the category, rather than replacing it.

The example format is used to specify examples in the spreadsheet that defines our inventory of relations. These examples are shown automatically in DTAG when the user invokes the help function for a given relation. The output from as.example can be pasted directly into the spreadsheet. You can insert several examples into the spreadsheet, separated by a blank line (use ctrl-enter in Google spreadsheets).


### Annotating word segments ###

  * **`segment <node> <segments>`**: segment the given node into smaller parts; opens a segment editor for the given node if `<segments>` is omitted. Eg, `segment 123` or `segment 123 auto|camper` (dependency graphs), `segment b17` or `segment b17 ¹hard²disk` (alignments). The segments are numbered with the superscript digits "¹²³" (press "shift+!altgr+1" or "`^+1`", similarly for 2 and 3) preceded by "`^`" (press "<sup>+</sup>") if there are more than 3 segments. These digits are used to identify the segments. If you insert a segment boundary, the vertical bar "|", the numbering is performed automatically by DTAG.
  * **alignment edges for segments:** specify the relevant segments in the edge label, eg when aligning "¹wind²shield" with "wind shield", simply specify alignment edges `0 ¹= 0` and `0 ²= 1`.
  * **dependency edges for segments:** specify the relevant segments in the edge label, eg when annotating internal dependency structure of "¹wind²shield", create alignment edges `0 ¹mod² 0`.

### Autoreplace ###

The autoreplacer can search an entire corpus for a given list of edge relations, and replace them with new relations. Here is what you need to do in order to use the autoreplacer:

  * Set the corpus you want to work with with the `corpus` command:<br><b><code>corpus /home/cdt/cdt/da/*.tag</code></b>
<ul><li>Start the autoreplacer by specifying the relations you want to replace, eg "mod" and "subj":<br><b><code>autoreplace -corpus mod subj</code></b>
</li><li>The autoreplacer shows the current match. The following commands are used to go to the next match (the files are saved automatically as the autoreplacer moves from one file to the next):<br>
<ul><li><b><code>=myrel</code></b>: replace the matching relation with the relation name "myrel" (eg, "dobj"), and proceed to next match.<br>
</li><li><b><code>=</code></b>: leave the matching relation unchanged, and proceed to the next match.</li></ul></li></ul>

<h3>Annotating morphology</h3>

<ul><li><b><code>autotag [-matches] [-default] &lt;feature&gt; &lt;files&gt;</code></b>: start the autotagger for the given feature on the current file, using the given files as training data. Eg, <code>autotag morph *.tag</code> will start the autotagger on the <code>morph</code> feature, using all tag-files in the current directory as training data. With the <code>-default</code> option, the autotagger reuses an existing autotagger lexicon if it already exists. With the <code>-matches</code> option, the autotagger only tags words that were matched by the last <code>find</code> command.<br>
</li><li><b><code>autotag -off</code></b>: turn off the autotagger.<br>
</li><li><b><code>autotagm</code></b>: a shorthand for <code>find $X[msd] =~ /^(NC|V|AN)/ ;; autotag morph -matches -default *.tag</code> which is used for morphological annotation in the CDT project.<br>
</li><li><b><code>&lt; &lt;value&gt;</code></b>: set the feature value of the current word in the autotagger. Shortcuts can be specified in the value string as "#1", "#2", etc. Eg, <code>&lt;word+s</code> and <code>&lt;#1+#2+s</code>.<br>
</li><li><b><code>&lt;position&gt; &lt; &lt;value&gt;</code></b>: set the feature value for the word with the given relative position in the autotagger. Eg, <code>37&lt;word+s</code>.<br>
</li><li><b><code>autotag -pos &lt;position&gt;</code></b>: move the autotagger to the word with the given position.<br>
</li><li><b><code>autotag -offset &lt;offset&gt;</code></b>: increment/decrement the offset in the autotagger with the specified amount. Eg, <code>autotag -offset -37</code>.</li></ul>

<h3>Annotating alignment graphs</h3>

<ul><li><b><code>&lt;nodes&gt; [&lt;label&gt;] &lt;nodes&gt;</code></b>: create alignment -- eg, <code>1+3 label 2..7</code> or <code>a1..3 a1..3</code> if you want to align the nodes 1..3 on the a-side with themselves. You do not have to provide a label.<br>
</li><li><b><code>del &lt;node&gt;</code></b>: delete all alignment edges at the given node, eg, <code>del a3</code>.<br>
</li><li><b><code>ok</code></b>: accept all the red edges proposed by the autoaligner.</li></ul>

Advanced commands:<br>
<br>
<ul><li><b><code>offset [=+-][ab][offset]</code></b>: specify offset for alignment graph, either absolutely ("=") or relatively ("+" and "-", with "+" as the default). This changes the numbering of the nodes, and hides negatively numbered nodes. Eg: <code>offset a30 b20</code>, <code>offset a-30</code>, <code>offset =a0 =b0</code>.<br>
</li><li><b><code>autoalign &lt;files&gt;</code>:</b> start autoaligner using the listed files as training material, eg, <code>autoalign *.atag</code>. You can save the alignment lexicon with the command <b><code>save &lt;file&gt;.alex</code></b> and reload the alignment lexicon the next time with <code>autoalign &lt;file&gt;.alex</code>.<br>
</li><li><b><code>autoalign -off</code></b>: turn off the autoaligner (started automatically by <code>opentask</code>).</li></ul>

<h3>Comparing annotations with diff</h3>

<ul><li><b><code>diff &lt;file&gt;</code></b>: compare the current dependency graph with the given dependency graph. Prints statistics and shows differences graphically. Eg: <code>diff 0502-it-morten.tag</code> (when working on <code>0502-it-iørn.tag</code>).<br>
</li><li><b><code>adiff &lt;file&gt;</code></b>: compare the current alignment with the given alignment. Prints statistics and shows differences graphically. Eg: <code>adiff 0502-da-it-morten.atag</code> (when working on <code>0502-da-it-iørn.atag</code>).<br>
</li><li><b><code>undiff</code></b>: turn off diff mode again.</li></ul>

<h3>Find and replace</h3>

DTAG has a sophisticated query language that can be used to search dependency graphs and alignments, extract tables, and perform automatic replace operations. The <a href='QueryTutorial.md'>DTAG query tutorial</a> provides a detailed description of the query language. The most important commands are summarized below.<br>
<br>
<ul><li><b><code>find [-corpus] &lt;constraint&gt;</code></b>: search the graph (or the entire corpus co nsisting of all dependency graphs) for all occurrences that match the given constraint. The constraint consists of simple constraints on labels, edges, and word order that can be combined with logical AND "&", OR "|", and NOT "!", as well as universal and existential quantifier expressions (<code>exist(&lt;var&gt;, &lt;constraint&gt;)</code> and <code>all(&lt;var&gt;, &lt;constraint&gt;)</code>. Examples:<br>
<ul><li><code>find $X subj $Y</code> <br><i>(all occurences of a subject $X and its head word $Y)</i>
</li><li><code>find $X =~ /^at$/</code>  <br><i>(all occurences of a word $X that matches the regular expression <code>/^at$/</code> ("<code>^</code>" = start of string, "$" = end of string)</i>
</li><li><code>find $X[msd] =~ /^NP/</code>  <br><i>(all occurrences of a word $X whose word class ("msd") starts with "NP" (a proper noun))</i>
</li><li><code>find ( $X expl $Y ) &amp; ( $X[lemma] =~ /^der$/ ) &amp; ( $X &gt; $Y )</code>  <br><i>(all occurences of the expletive word $X with lemma "der" which has been analyzed as an "expl" dependent of a preceding word $Y)</i>
</li></ul></li><li><b><code>next</code></b>: goto the next match in the search (can be abbreviated as "n").<br>
</li><li><b><code>prev</code></b>: goto the previous match in the search (can be abbreviated as "p").</li></ul>

<h3>Tasks and revision control</h3>

<ul><li><b><code>opentask</code></b>: open the first unfinished task that has been assigned to you (the <i>current task</i>).<br>
</li><li><b><code>closetask dim=status ...</code></b>: mark the current task as closed with the specified new status (see the section "Annotation status"), eg, tell DTAG that you are completely done with it so that <code>opentask</code> will return another task.<br>
</li><li><b><code>save</code></b>: save your current work on your hard disk (you should do this frequently).<br>
</li><li><b><code>update</code></b>: update your local copy of the central CDT repository with all the annotations.<br>
</li><li><b><code>commit</code></b>: upload your local annotations to the central CDT repository.<br>
</li><li><b><code>exit</code></b>: close DTAG (without saving!)<br>
</li><li><b><code>tasks</code></b>: open your task list in an editor; you can then reorder the tasks (if you want to do them in a different order), add tasks, or reopen tasks that you have closed inadvertently.</li></ul>


<h3>Annotation status in the CDT project</h3>

The following commands are used to query or set the status of the<br>
annotated files:<br>
<br>
<ul><li><b><code>closetask &lt;dim&gt;=&lt;status&gt; ...</code></b>: close the current task and specify the dimensions that have changed status. Example: "closetask m=1 s=d d=f".<br>
</li><li><b><code>status</code></b>: display the annotation status for the current file<br>
</li><li><b><code>statusall &lt;dir1&gt; &lt;dir2&gt; &lt;dir3&gt; ...</code></b>: display the number of texts in the specified directories that have been annotated in each dimension, grouped by status; if there are no specified directories, all directories are shown. Example: "statusall da it da-it", "statusall".<br>
</li><li><b><code>setstatus &lt;dim1&gt;=&lt;status1&gt; &lt;dim2&gt;=&lt;status2&gt; ...</code>:</b>  set the status of the current text for the specified dimensions. Example: "setstatus m=1 s=f".<br>
</li><li><b><code>findfiles &lt;dim&gt;=&lt;status&gt; &lt;files&gt;</code>:</b> find all texts where the given dimension has the specified status; if no files are specified, use all files in the current directory by default.</li></ul>

In the CDT project, all annotated files have an associated annotation<br>
status with respect to the following five dimensions:<br>
<br>
<pre>
KEY DIMENSION   DESCRIPTION<br>
p   postag      Part-of-speech tags<br>
s   syntax      Syntactic annotation<br>
m   morphology  Morphological annotation<br>
d   discourse   Discourse annotation<br>
a   alignment   Alignment<br>
</pre>

Each dimension can be abbreviated with a key (eg, "s" for syntax). The<br>
possible status values for each dimension are listed below:<br>
<br>
<pre>
KEY STATUS          DESCRIPTION<br>
none            no annotation<br>
auto            automatic annotation<br>
1   first           first-pass independent human annotation (before discussion)<br>
d   discussed       discussed with other annotators, possibly corrected<br>
f   final           final revision complete<br>
f1  final           final version that has not been discussed with other annotators<br>
outdated-final  outdated-final status (for pre-CDT treebank annotations, ie, Danish and English syntax)<br>
</pre>


<h3>Loading and saving files in various formats</h3>

DTAG supports two native formats: ".tag" for dependency graphs, and ".atag" for alignments. The ".tag" format is a line-based format in which every line of the form<br>
<br>
<blockquote><code>&lt;W in="ipos1:itype1|ipos2:itype2|..." out="opos1:otype1|..." a1="f1" a2="f2" ...&gt;token&lt;/W&gt;</code></blockquote>

encodes a graph node with token given by <code>token</code>, attribute value pairs a1=f1,...,an=fn, and the in- and out-edges given by the "in" and "out" attributes. Each edge is encoded as a pair "rpos:type" where "rpos" is the relative position of the other node on the edge (-1=previous line, 1=next line, 10=10 lines after, etc.) and "type" is the edge type.<br>
<br>
<ul><li><b><code>load &lt;file&gt;</code></b>: load the given file, assuming the format given by the file name extension.<br>
</li><li><b><code>load -&lt;format&gt; &lt;file&gt;</code>:</b> load the given file, using the specified format (".tag", ".atag", ".malt", ".conll")<br>
</li><li><b><code>save &lt;file&gt;</code></b>: save the given file, using the format given by the file name extension.<br>
</li><li><b><code>save -&lt;format&gt; &lt;file&gt;</code>:</b> save the given file, using the specified format (".tag", ".atag", ".malt", ".conll")<br>
</li><li><b><code>option conll_postag=&lt;var&gt;</code></b>: when saving in conll-format, the "postag" part-of-speech feature is read off from node attribute <code>var</code>. When using the PAROLE "msd" attribute, a special conversion filter kicks in to convert the complex PAROLE tag into a 1-2 letter part-of-speech tag and features for number, case, definiteness, etc.<br>
</li><li><b><code>option conll_cpostag=&lt;var&gt;</code></b>: when saving in conll-format, the "cpostag" course part-of-pseech feature is read off from node attribute <code>var</code>. This option is ignored if <code>conll_postag</code> is set to "msd".</li></ul>





<h3>Other useful commands</h3>

<ul><li><b><code>defaults</code></b>: reload all dtagrc initialization files.<br>
</li><li><b><code>ls &lt;pattern&gt;</code></b>: list all files in current directory that match the pattern <code>&lt;pattern&gt;</code>; the wild-card character is "<code>*</code>". Eg: <code>ls 0001*.tag</code>. Equivalent to <code>!ls &lt;pattern&gt;</code>.<br>
</li><li><b><code>pwd</code></b>: print current working directory. Equivalent to <code>!pwd</code>.<br>
</li><li><b><code>cd &lt;directory&gt;</code></b>: change to the given directory. Eg: <code>cd da-it</code>; <code>cd /home/cdt/cdt</code>.<br>
</li><li><b><code>cdt &lt;directory&gt;</code></b>: change to the given cdt directory in $CDTHOME. Eg: <code>cdt da</code>
</li><li><b><code>lpr</code></b>: print the currently annotated text to the default printer.<br>
</li><li><b><code>makemanual</code></b>: compile the CDT manual based on the relation spreadsheet combined with statistics collected from the latest annotations in the cdt/first directories. Run "update" first if you want the manual to be generated from the newest files in the repository. Outdated files in the cdt/first directories can be deleted either locally (using the "rm" UNIX command) or in the svn repository (using the "svn rm" command). If files are deleted locally, they will be restored automatically the next time the local copy of the repository is updated (eg, after "update" or "commit"). For example, in DTAG you can run the following commands to see the files in the cdt/first directory, delete all syntax files created by morten locally, and syntax files with id 0001 created by matthias globally (wildcard "<code>*</code>" matches any sequence of characters):</li></ul>

<blockquote><code>cdt first</code><br>
<code>ls</code><br>
<code>cd syntax</code><br>
<code>ls *morten*</code><br>
<code>!rm *morten*</code><br>
<code>ls</code><br>
<code>!svn rm 0001*matthias*</code></blockquote>

<blockquote>Note that you should only delete first-files globally if you have made a major change in annotation scheme: the first-files are also used to compute confusion scores, and in terms of the applications of the treebank in natural language processing it is much more valuable to have accurate confusion scores that reflect the true state of the treebank, than to have the latest agreement scores. If all you want are the latest agreement scores, you should delete the files locally, create the manual, save the generated manual with the agreement and confusion scores, run "update" so that you recreate the deleted "first" files, and then recreate the manual with "makemanual" so the confusion tables remain accurate.