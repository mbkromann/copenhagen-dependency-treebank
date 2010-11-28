# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 NAME

DTAG::Interpreter - DTAG command line interface

=head1 DESCRIPTION

DTAG::Interpreter - command line interface in DTAG

=head1 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Interpreter;

# Pragmas
use strict;

# Required modules
use Term::ANSIColor;
use Term::ReadLine;
use Term::ReadKey;
use Data::Dumper;
use Parse::RecDescent;
use LWP::Simple;
use XML::Writer;
use XML::Parser;
use PerlIO;
use IO qw(File);
use File::Basename;
use Encode qw(decode decode_utf8 from_to);
use Time::HiRes qw(time sleep);
use Encode;

# Required DTAG modules 
require DTAG::Lexicon;
require DTAG::LexInput;
require DTAG::Learner;

# Interpreted Perl: arg-list
my @perl_args = ();

# Variables
my $graphid = 0;
my $interpreter = undef;
my $viewer = 0;
my $tiger_dependency = 1;
my ($L, $G, $I);

# Signals
sub catch_signal {
	my $signame = shift;
	die "DTAG: detected signal $signame\n";
}
$SIG{INT} = \&catch_signal;

# Fields in relation names
# Relation = [$shortname, $longname, 
#   @immediateparents, @transitiveparents, @immediatechildren,
#   $shortdescription, $longdescription, $examples,
#   $supertypes, $lineno, $see]
my $REL_SNAME = 0;
my $REL_LNAME = 1;
my $REL_IPARENTS = 2;
my $REL_TPARENTS = 3;
my $REL_ICHILDREN = 4;
my $REL_SDESCR = 5;
my $REL_LDESCR = 6;
my $REL_EX = 7;
my $REL_DEPRECATED = 8;
my $REL_STYPES = 9;
my $REL_LINENO = 10;
my $REL_CHILDCNT = 11;
my $REL_TCHILDCNT = 12;
my $REL_SEE = 13;
my $REL_CONN = 14;


# Debugging
my $debug_relset = undef;
#open(my $debug_relset, ">:encoding(utf8)", "/tmp/dtag.relset.dbg");


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/HELP.pl
## ------------------------------------------------------------

my $commands = {
	'<return>' => ['update follow-file', '<return>'],
	'#' => ['ignore line', '# $comment'],
	'!' => ['execute shell command', '! $shell-command'],
	'cd'   => ['change directory', 'cd $dir'],
	'clear'=> ['clear graph or lexicon', 'clear [-tag|-lex]'],
	'close'=> ['close current graph', 'close'],
	'comment'=>['insert comment in TAG file', 'comment $pos $comment'],
	'corpus'=>['set corpus files', 'corpus [-clear] [-add] $file ...'],
	'del'  => ['delete node or edge', 'del $node [$etype $node]'],
	'diff' => ['show differences between graphs', 'diff $file'],
	'edge' => ['create new edge', '[edge] $nodein $etype $nodeout'],
	'edit' => ['edit node or edge', 'edit $node [$var[=$value]] ...'],
	'exit' => ['exit the tagger', 'exit'],
	'find' => ['find matches in graph', 'find [-corpus] [-replace($cmd)]... [-key($template)] [-text($template)] $query'],
	'follow'=>['print graph as PostScript file for each blank line', 'follow [$file]'],
	'goto' => ['goto match of search', 'goto [M|G][$id|+|-]'],
	'graphs'=>['display list of open graphs', 'graphs'],
	'help' => ['print help for specified command', 'help [$command]'],
	'inline'=>['insert inline DTAG command in TAG file', 'inline $pos $dtag'],
	'layout' => ['specify layout for nodes and edges', 'layout $command'],
	'lexicon'=> ['specify lexicon name', 'lexicon $lex'],
	'load' => ['load graph or lexicon', 'load [-tag|-lex|-match] [$file]'],
	'lookup'=>['lookup lexemes found at start of string', 'lookup $string'],
	'lookupw'=>['lookup lexemes matching string', 'lookupw $string'],
	'ls' => ['list files in current directory', 'ls $lsargs'],
	'macro'	=> ['define/delete macro', 'macro $macro $command'],
	'macros'=> ['list macros', 'macros'],
	'matches' => ['list matches in search', 'matches [-num] [-reverse] [-nomatch] [-stats([key|text],[key|text])]'],
	'mkdir' =>['make directory', 'mkdir $dir'],
	'move' => ['move node', 'move $pos1 $pos2'],
	'new'  => ['create new graph', 'new'],
	'next' => ['display next match in search', 'next [M|G]'],
	'node' => ['create new node', '[node [[+-]pos]] $phon [$var=$value] ...'],
	'offset'=>['set offset for node numbering', 'offset [=+-]$offset'],
	'perl' => ['evaluate Perl expression ($G=graph, $I=interpreter, $L=lexicon)', 'perl $expr'],
	'prev' => ['display previous match in search', 'prev [M|G]'],
	'print'=> ['print graph as PostScript file', 'print [$file]'],
	'pwd' =>  ['print working directory', 'pwd'],
	'rm' =>   ['remove file', 'rm $file'],
	'rmdir' =>   ['remove directory', 'rmdir $dir'],
	'save' => ['save graph or lexicon', 'save [-tag|-lex|-match|-conll|-malt|-xml] [$file]'],
	'script'=>['execute script', 'script $file'],
	'server'=>['specify server directory', 'server $dir'],
	'shell' =>['execute shell command', 'shell $cmd'],
	'show' => ['print only nodes in graph with indices between $imin and $imax', 'show $imin[-$imax]'],
	'sleep' =>['sleep specified number of seconds', 'sleep $seconds'],
	'style' => ['specify formatting for given style', 'style $style $options'],
	'touch' => ['mark current graph as modified', 'touch'],
	'undiff'=> ['reset diff', 'undiff'],
	'unix' => ['execute unix command', 'unix $cmd'],
	'vars'  => ['declare or undeclare variables', 'vars [-$var] [+$var[:$abbrev]] ...'],
	'view' => ['view graph', 'view [$node]'],
	'viewer'=>['open GV PostScript viewer', 'viewer'],
};


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/QUERIES.pl
## ------------------------------------------------------------

# Query parser
my $query_parser;
$::RD_HINT = 1;

# Query language grammar
my $query_grammar = q{
	FindExpression : 
		Option(s?) Query Action(s?)
			{	my $hash = {};
				foreach my $h (@{$item[1]}) {
					map {$hash->{$_} = $h->{$_}} keys(%$h);
				}
				{ 'options' => $hash,
					'query' => $item[2], 
					'actions' => $item[3]} }

	Option : 
		  '-corpus' 	{{'corpus' => 1}}
		| '-debug'		{{'debug' => 1}}
		| '-dump'		{{'dump' => 1}}
		| '-parse'		{{'debug_parse' => 1}}
		| '-dnf'		{{'debug_dnf' => 1}}
		| '-yes'		{{'replace-all' => 1}}
		| '-maxtime=' /[0-9]+/
						{{'maxtime' => $item[2]}}
		| '-maxmatch=' /[0-9]+/
						{{'maxmatch' => $item[2]}}
		| '-onOpen(' <leftop: DTAGCommand ";" DTAGCommand> ')'
			{ 'opOpen' => FindActionDTAG->new(@{$item[2]}) }
		| '-onClose(' <leftop: DTAGCommand ";" DTAGCommand> ')'
			{ 'onClose' => FindActionDTAG->new(@{$item[2]}) }
		| '-vars(' <leftop: NodeVariableDeclaration "," NodeVariableDeclaration > ')'
			{	my $hash = {}; 
				map {$hash->{$_->[0]} = ($_->[1] || "")} @{$item[2]};
				{'vars' => $hash }; }

	Action :
		  '-do(' <leftop: DTAGCommand ";" DTAGCommand> ')'
			{ FindActionDTAG->new(@{$item[2]}) }
		| <error>

	Query :
		  UnaryQuery ( "∨" | "||" | "|" | "OR" | "or" ) <leftop: UnaryQuery ( "∨" | "||" | "|" | "OR" | "or" ) UnaryQuery>
			{ FindOR->new($item[1], DTAG::Interpreter::objects(@{$item[3]})) }
		| UnaryQuery /∧|\&\&|\&|AND|and/ <leftop: UnaryQuery /∧|\&\&|\&|AND|and/ UnaryQuery>
			{ FindAND->new($item[1], DTAG::Interpreter::objects(@{$item[3]})) }
		| UnaryQuery ( "→" | "⇒" | "IMPLIES" | "implies" | "->") UnaryQuery
			{ FindOR->new(FindNOT->new($item[1]), $item[3]) }
		| UnaryQuery ( "←" | "⇐" | "IF" | "if" | "<-") UnaryQuery
			{ FindOR->new(FindNOT->new($item[3]), $item[1]) }
		| UnaryQuery
			{ $item[1] }
		

	UnaryQuery :
		  '(' Query ')'
			{ $item[2] }
		| ( "¬" | "!" | "NOT" | "not" ) UnaryQuery
			{ FindNOT->new($item[2]) }
		| ExistQuantifier (NodeVariableDeclaration | Node) '(' Query ')'
			{ FindEXIST->new($item[2], $item[4]) }
		| ExistQuantifier '(' (NodeVariableDeclaration | Node) ',' Query ')'
			{ FindEXIST->new($item[3], $item[5]) }
		| AllQuantifier (NodeVariableDeclaration | Node) '(' Query ')'
			{	FindEXIST->new($item[2], FindNOT->new($item[4]))
				->setNegated() }
		| AllQuantifier '(' (NodeVariableDeclaration | Node) ',' Query ')'
			{	FindEXIST->new($item[3], FindNOT->new($item[5]))
				->setNegated() }
		| SimpleQuery

	ExistQuantifier :
		( "∃" | "EXISTS" | "EXIST" | "E" | "exists" | "exist" ) 

	AllQuantifier :
		( "∀" | "ALL" | "A" | "all" )

	SimpleQuery : 
		  StringValueQuery
		| AdjacencyQuery
		| NumberValueQuery
		| GraphQuery
		| AlignmentQuery

	StringValueQuery : 
		  StringValue 'eq' StringValue
			{ FindStringEQ->new($item[1], $item[3]) }
		| StringValue 'ne' StringValue
			{ FindStringEQ->new($item[1], $item[3])->setNegated() }
		| StringValue '=~' RegularExpression
			{ FindStringRegExp->new($item[3], $item[1]) }
		| StringValue '!~' RegularExpression
			{ FindStringRegExp->new($item[3], $item[1])->setNegated() }

	NumberValueQuery :
		  NumberValue ( "==" | "=" ) NumberValue
			{ FindNumberEQ->new($item[1], $item[3]) }
		| NumberValue ( "!=" | "≠" ) NumberValue 
			{ FindNumberEQ->new($item[1], $item[3])->setNegated() }
		| NumberValue ( "<=" | "≤" ) NumberValue
			{ FindNumberGT->new($item[1], $item[3])->setNegated() }
		| NumberValue ( ">=" | "≥" ) NumberValue
			{ FindNumberLT->new($item[1], $item[3])->setNegated() }
		| NumberValue "<" NumberValue
			{ FindNumberLT->new($item[1], $item[3]) }
		| NumberValue ">" NumberValue
			{ FindNumberGT->new($item[1], $item[3]) }

	AdjacencyQuery : 
		  Node '>>' Node
			{ FindADJ->new($item[1], $item[3], [[1,1]], -1) }
		| Node '<<' Node
			{ FindADJ->new($item[1], $item[3], [[1,1]], 1) }
		| Node '>' Range '>' Node
			{ FindADJ->new($item[1], $item[5], $item[3], -1) }
		| Node '<' Range '<' Node
			{ FindADJ->new($item[1], $item[5], $item[3], 1) }

	GraphQuery : 
		  Node RelationPattern Node
		  	{ FindEdge->new($item[1], $item[3], $item[2]) }
		| Node "path(" PathPattern ")" Node
			{ FindPath->new($item[1], $item[5], $item[3]) }
	
	AlignmentQuery : 
		"@(" NodeList ";" NodeList ")"
			{ FindAlign->new($item[2], $item[4], undef) }
		| "@" RelationPattern "(" NodeList ";" NodeList ")"
			{ FindAlign->new($item[4], $item[6], $item[2]) }
	
	RelationPattern :
		"isa(" Type "," Identifier ")"
			{ FindMatchStringIsa->new($item[2], $item[4]) }
		| "isa(" Type ")"
			{ FindMatchStringIsa->new($item[2]) }
		| /\/[^\/]+\//
			{ FindMatchStringRegExp->new($item[1]) }
		| RelationName
			{ FindMatchStringEQ->new($item[1]) }

	RelationName : 
		  '"' StringWithNoDoubleQuotes '"'
			{ $item[2] }
		| Identifier

	NodeList : 
		"!" <leftop: Node "," Node>
			{ ("!", $item[2]) }
		| <leftop: Node "," Node>
			{ $item[1] }
	
	Type : 
		  UnaryType "+" <leftop: UnaryType "+" UnaryType >
		    { FindTypePlus->new($item[1], @{$item[3]}) }
		| UnaryType "-" <leftop: UnaryType "-" UnaryType >
		    { FindTypeMinus->new($item[1], @{$item[3]}) }
		| UnaryType "|" <leftop: UnaryType "|" UnaryType >
		    { FindTypeOr->new($item[1], @{$item[3]}) }
		| "-" UnaryType
		    { FindTypeNot->new($item[2]) }
		| UnaryType

	UnaryType :
		  "(" Type ")"
			{ $item[2] } 
		| "!" TypeName
			{ FindTypeAtomic->new($item[2], 1) }
		| TypeName
			{ FindTypeAtomic->new($item[1]) }

	TypeName : 
		  '"' StringWithNoDoubleQuotes '"' 
		  	{ $item[2] }
		| Identifier
		  	{ $item[1] }

	PathPattern : 
		UnaryPathPattern(s)
		
	UnaryPathPattern : 
		  '(' PathPattern ')'
		  	{ $item[2] }
		| '>' RelationPattern
		  	{ ['>', $item[2]] }
		| '<' RelationPattern
			{ ['<', $item[2]] }
		| '{' PathPattern '}ُ+'
			{ ['+', $item[2], 1, undef] }
		| '{' PathPattern '}*' 
			{ ['+', $item[2], 0, undef] }
		| '{' PathPattern '}(' Integer '..' Integer ')'
			{ ['+', $item[2], $item[4], $item[6]] }
		| '{' PathPattern '}(' '..' Integer ')'
			{ ['+', $item[2], 0, $item[5]] }
		| '{' PathPattern '}(' Integer '..' ')'
			{ ['+', $item[2], $item[4], undef] }
		| '{' PathPattern '}(' Integer ')'
			{ ['+', $item[2], $item[4], $item[4]] }

	GraphKey : /[a-zA-Z]+/

	Value : 
		<skip: '[ \t]*'> StringValue
		| <skip: '[ \t]*'> NumberValue

	StringValue :
		  'etypes(' Node ',' Node ')'
		  	{ FindStringValueEtype->new($item[2], $item[4]) }
		| 'etypes(' Node RelationPattern Node ')'
		  	{ FindStringValueEtype->new($item[2], $item[4], $item[3]) }
		| IntegerValue '[' Feature ']'
		  	{ FindStringValueNodeFeature->new($item[1], $item[3]) }
		| Node "[]"
			{ FindStringValueNodeFeature->new(
				FindNumberValueNode->new($item[1]), undef) }
		| '"' /[^"]*/ '"'
			{ FindStringValue->new($item[2]) }

	IntegerValue : 
		Node
			{ FindNumberValueNode->new($item[1]) }
		| Integer
			{ FindNumberValue->new($item[1]) }

	NumberValue :
		  IntegerValue '[' Feature ']'
		  	{ FindNumberValueNodeFeature->new($item[1], $item[3]) }
		| Float
			{ FindNumberValue->new($item[1]) }
		| IntegerValue
			{ $item[1] }
		| "is(" Query ")"
			{ FindNumberValueQuery->new($item[2]) }
	
	Range :
		<leftop: SimpleRange "," SimpleRange>

	SimpleRange : 
		Integer ".." Integer
			{ [$item[1], $item[3]] }
		| Integer
			{ [$item[1], $item[1]] }

	DTAGCommand :
		<skip: ''> DTAGCommandSegment(s)
		| <error>

	DTAGCommandSegment :
		'`' Value '`'
			{$item[2]}
		| Node
			{ FindNumberValueNode->new($item[1]) }
	 	| DTAGCommandString
			{ FindStringValue->new($item[1]) }
		| '(' DTAGCommandString ')'
			{ FindStringValue->new('(' . $item[2] . ')') }

	DTAGCommandString :
		/[^\\\\$()`]+/
		| '\t' { '	' }
		| '\n' { '\n' }
		| '\r' { '\r' }
		| '\(' { "(" }
		| '\)' { ")" }
		| '\\\' '\\\' { "\\\" }

	NodeVariableDeclaration :
		Node "@" GraphKey
			{ [$item[1], $item[3]] }

	RegularExpression : 
		/\/[^\/]*\//
			{ $item[1] }

	Node : /\$[a-zA-Z][a-zA-Z0-9_]*/
		| /[0-9]+/

	Feature : 
		'"' /[^"]+/ '"'
			{ $item[2] }
		| /[^]]+/
			{ $item[1]}

	FileName : '"' StringWithNoBlanksNoQuotes '"'
		{ $item[2] }

	Identifier :
		/[^()\s,;+=<>≤≥|-]+/

	StringWithNoDoubleQuotes : 
		/[^"]+/

	StringWithEscapedSlash : 
		/([^\/]*\/)*[^\/]*/

	StringWithEscapedParentheses : 
		/([^()]+(\\(|\\)))*[^()]*/

	StringWithEscapedParenthesesNoBlanks :
		/[^()\s]+((\\(|\\))[^()\s]*)*/

	StringWithEscapedParenthesesNoBlanksNoQuotes :
		/[^()"\s]+((\\(|\\))[^()"\s]*)*/

	StringWithNoBlanksNoQuotes :
		/[^"\s]+/

	Integer : 
		/[-+]?[0-9]+/

	Float : 
		/[-+]?[0-9]+(\.[0-9]+)?/

};

sub objects {
	my $list = [];
	while (@_) {
		my $arg = shift;
		push @$list, $arg
			if (ref($arg));
	}
	return @$list;
}

# Parser object
#my $query_parser = undef;
#$Parse::RecDescent::skip = '';


# Find all subjects that have been aligned to non-subjects.
# find exists($ys, $xs subj $ys) 
# 	& ! exists($xt, exists($yt, ($xt subj $yt)) & @($xs, $xt))
#TE=∃   FA=∀
# find E($ys, $xs subj $ys) 
# 	& ! E($xt, ∃($yt, ($xt subj $yt)) & @($xs,$xt))
# find ∃($ys, $xs@a & $xs subj $ys) 
# 	& ! ∃($xt, $xt@b & ∃($yt, ($xt subj $yt)) & @($xs, $xt))


# @($x,...;$y,...)					# alignment without label constraint
# @($x,...;$y,...) == $label		# alignment with label
# @($x,...;$y,...) =~ /$label/		# alignment with matching label
# @$A($x,...;$y,...) ...            # as before, but with alignment node $A
#

# Functions
# in($A): in-degree
# out($A): out-degree
# $x[$var]: node feature value
# $x : node position


# find $x@a & $y@b & $A@(a,b) & $A@($x,$y,$z,...):label & 

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/_conll_msd2features_table.pl
## ------------------------------------------------------------


my $conll_msd2features_table = {
    # adjective
    'A' => [
        # position 3
        [ 'degree',
          { 'A' => 'abs',
            'C' => 'comp',
            'P' => 'pos',
            'S' => 'sup' } ],
        # position 4
        [ 'gender',
          { 'C' => 'common',
            'N' => 'neuter' } ],
        # position 5
        [ 'number',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 6
        [ 'case',
          { 'G' => 'gen',
            'U' => 'unmarked' } ],
        # position 7
        'none',
        # position 8
        [ 'def',
          { 'D' => 'def',
            'I' => 'indef' }],
        # position 9
        [ 'transcat',
          { 'R' => 'adverbial',
            'U' => 'unmarked' } ] ],
    
    # noun
    'N' => [
        # position 3
        [ 'gender',
          { 'C' => 'common',
            'N' => 'neuter' } ],
        # position 4
        [ 'number',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 5
        [ 'case',
          { 'G' => 'gen',
            'U' => 'unmarked' } ],
        # position 6
        'none',
        # position 7
        'none',
        # position 8
        [ 'def',
          { 'D' => 'def',
            'I' => 'indef' } ] ],
    
    # pronoun
    'P' => [
        # position 3
        [ 'person',
          { '1' => '1',
            '2' => '2',
            '3' => '3' } ],
        # position 4
        [ 'gender',
          { 'C' => 'common',
            'N' => 'neuter' } ],
        # position 5
        [ 'number',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 6
        [ 'case',
          { 'N' => 'nom',
            'G' => 'gen',
            'U' => 'unmarked' } ],
        # position 7
        [ 'possessor',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 8
        [ 'reflexive',
          { 'N' => 'no',
            'Y' => 'yes' } ],
        # position 9
        [ 'register',
          { 'U' => 'unmarked',
            'O' => 'obsolete',
            'F' => 'formal',
            'P' => 'polite' } ],
        ],
    
    # adverb
    'RG' => [
        # position 3
        [ 'degree',
          { 'A' => 'abs',
            'C' => 'comp',
            'P' => 'pos',
            'S' => 'sup',
            'U' => 'unmarked' } ] ],
    
    # verb
    'V' => [
        # position 3
        [ 'mood',
          { 'D' => 'indic',
            'M' => 'imper',
            'P' => 'partic',
            'G' => 'gerund',
            'F' => 'infin' } ],
        # position 4
        [ 'tense',
          { 'R' => 'present',
            'A' => 'past' } ],
        # position 5
        [ 'person',
          { '1' => '1',
            '2' => '2',
            '3' => '3' } ],
        # position 6
        [ 'number',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 7
        [ 'gender',
          { 'C' => 'common',
            'N' => 'neuter' } ],
        # position 8
        [ 'definiteness',
          { 'D' => 'def',
            'I' => 'indef' } ],
        # position 9
        [ 'transcat',
          { 'A' => 'adject',
            'R' => 'adverb',
            'U' => 'unmarked' } ],
        # position 10
        [ 'voice',
          { 'A' => 'active',
            'P' => 'passive' } ],
        # position 11
        [ 'case',
          { 'N' => 'nom',
            'G' => 'gen',
            'U' => 'unmarked' } ] ]
    };


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/abort.pl
## ------------------------------------------------------------

sub abort {
	my $self = shift;
	$self->{'abort'} = shift if (@_);
	return $self->{'abort'};
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/binmode.pl
## ------------------------------------------------------------

sub binmode {
	my $self = shift;
	return $self->var('binmode', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_adiff.pl
## ------------------------------------------------------------

sub cmd_adiff {
	my $self = shift;
	my $graph = shift;
	my $files = shift;
	
	# Open individual graphs
	my @graphs = ();
	foreach my $file (split(/ +/, $files)) {
		print "opening $file\n";
		$self->cmd_load_atag($graph, $file);
		$graph = $self->graph();
		push @graphs, $graph;
	}

    # Create new alignment object and add it to DTAG's list of graphs
    my $align = DTAG::Alignment->new($self);
    push @{$self->{'graphs'}}, $align;
    $self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# Specify graphs in alignment
	my $translate = {};
	my $first = $graphs[0];
	my $n = scalar(@graphs);
	for (my $i = 0; $i < $n; ++$i) {
		if ($i == 0) {
			$translate->{"0a"} = "a";
			$translate->{"0b"} = "b";
			$align->add_graph("a", $first->graph("a"));
		} elsif ($i % 2 == 1) {
			$translate->{$i . "b"} = chr(97 + $i);
			$translate->{$i . "a"} = chr(97 + $i + 1);
		} else {
			$translate->{$i . "a"} = chr(97 + $i);
			$translate->{$i . "b"} = chr(97 + $i + 1);
		}
		$align->add_graph(chr(97 + $i + 1), 
			$first->graph(chr(97 + (($i + 1) % 2))));
	}

	# Translate edges
	my $edgetbl = {};
	for (my $i = 0; $i < scalar(@graphs); ++$i) {
		$graph = $graphs[$i];
		foreach my $e (@{$graph->edges()}) {
			# Create new edge
			my $enew = $e->clone();
			$enew->inkey($translate->{$i . $e->inkey()});
			$enew->outkey($translate->{$i . $e->outkey()});
			$enew->format(4);
			$enew->creator($i + 1);
			$align->add_edge($enew);

			# Add old edge to $edgetbl
			my $estr = $e->string();
			$edgetbl->{$estr} = [] if (ref($edgetbl->{$estr}) ne 'ARRAY');
			push @{$edgetbl->{$estr}}, 
				$enew;
		}
	}

	# Check whether edges differ
	my $statistics = [];
	for (my $i = 0; $i <= $n; ++$i) {
		$statistics->[$i] = [];
		for (my $j = 0; $j <= $n; ++$j) {
			$statistics->[$i][$j] = 0;
		}
	}
	foreach my $e (keys(%$edgetbl)) {
		my $elist = $edgetbl->{$e};

		# Calculate statistics
		my $count = scalar(@$elist);
		$statistics->[0][$count] += $count;
		$statistics->[0][0] += $count;
		foreach my $edge (@$elist) {
			$statistics->[$edge->creator()][$count] += 1;
			$statistics->[$edge->creator()][0] += 1;
		}

		# Mark edges not shared by all annotators
		if (scalar(@$elist) < $n) {
			foreach my $edge (@$elist) {
				$edge->format(1);
			}
		}
	}

	# Print statistics
	print "\nCOUNTS:\n\n";
	for (my $i = -1; $i <= $n; ++$i) {
		printf("%8s", "") if ($i < 0);
		printf("%8s", "TOTAL") if ($i == 0);
		printf("%8s", "ANN$i") if ($i > 0);

		for (my $j = 0; $j <= $n; ++$j) {
			printf "%8s", ($j == 0 ? "TOTAL" : "$j-AGR") if ($i < 0);
			printf "%8s", $statistics->[$i][$j] if ($i >= 0);
		}
		print "\n";
	}

	print "\nPERCENTAGES OF ROW TOTAL:\n\n";
	for (my $i = -1; $i <= $n; ++$i) {
		printf("%8s", "") if ($i < 0);
		printf("%8s", "TOTAL") if ($i == 0);
		printf("%8s", "ANN$i") if ($i > 0);

		for (my $j = 0; $j <= $n; ++$j) {
			printf "%8s", ($j == 0 ? "TOTAL" : "$j-AGR") if ($i < 0);
			printf("  % 3.2f", $statistics->[$i][$j]
				/ $statistics->[$i][0] * 100) if ($i >= 0);
		}
		print "\n";
	}


	# Update graph
	$self->cmd_return();

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_afilter.pl
## ------------------------------------------------------------

# Remove a dependent whƣch isn't source-linked to any target node? 
my $remove_unlinked_dependent = 0;

# Remove a dependent where no transitive source parent is linked to a
# target node? 
my $remove_unlinked_transitive_parent = 1;

# Remove a dependent which is source-linked to another target node,
# but not the governor?
my $remove_doubly_linked = 1;

# Specify tag feature
sub cmd_afilter {
	my $self = shift;
	my $graph = shift;
	my $afile = shift;
	my $current_graph = $self->{'graph'};

	# Load alignment
	$graph->mtime(1);
	$self->cmd_load($graph, '-atag', $afile);
	my $alignment = $self->graph();

	# Check that alignment is loaded
	if (! UNIVERSAL::isa($alignment, 'DTAG::Alignment')) {
		error("invalid alignment graph: aborting afilter");
		return 1;
	}

	# Find source graph, source key, and target key
	my ($tkey, $skey, $source);
	my $graphfile = $graph->file();
	$graphfile =~ s/^.*\/([^\/]*)$/$1/g;
	foreach my $key (keys(%{$alignment->graphs()})) {
		my $keyfile = $alignment->graph($key)->file();
		$keyfile =~ s/^.*\/([^\/]*)$/$1/g;
		print "graph=$graphfile key=$keyfile\n";
		if ($graphfile eq $keyfile) {
			# Found target
			$tkey = $key;
		} else {
			# Found source
			$skey = $key;
			$source = $alignment->graph($skey);
		}
	}

	# Exit if source and target key not found
	if (! $skey || ! $tkey) {
		error("target graph does not match any graph in alignment");
		return 1;
	}
	print "source=". $source->file() . " target=" . $graph->file() . "\n";

	# Process all dependency edges in target
	$graph->do_edges(\&filter_edge, $alignment, $source, $graph, $skey, $tkey);
	
	# Return to original graph
	$self->{'graph'} = $current_graph;
	$self->cmd_return();

	# Return
	return 1;
}

sub filter_edge {
	my $e = shift;
	my $alignment = shift;
	my $source = shift;
	my $target = shift;
	my $skey = shift;
	my $tkey = shift;
	#print "e=$e alignment=$alignment source=$source target=$target skey=$skey tkey=$tkey\n";

	# Find nodes linked to dependent, and the linked parents
	if ($target->is_dependent($e)) {
		my $node = $tkey . $e->in();
		my $parent = $tkey . $e->out();
		my $nodes = find_linked_nodes($alignment, $node);
		my $parents = find_linked_parents($alignment, $source, $skey, $tkey, $node);

		# Determine what to do
		my $accept = 0;
		if ($nodes->{$parent}) {
			# Governor among linked nodes: accept
			$accept = 1;
		} elsif ($parents->{$parent}) {
			# Governor among linked parents: accept
			$accept = 1
		} elsif (! grep {$_ =~ /^$skey/} keys(%$nodes)) {
			# Dependent not linked to any source nodes
			$accept = ! $remove_unlinked_dependent;
		} elsif (grep {$_ =~ /^$tkey/} keys(%$parents)) {
			# Dependent has other linked parents, but governor not among them
			$accept = ! $remove_doubly_linked;
		} else {
			# Dependent has no transitive target parents: reject
			$accept = ! $remove_unlinked_transitive_parent;
		}

		# Delete dependency if not accepted
		$target->edge_del($e) if (! $accept);
	}
}

sub find_linked_parents {
	my $alignment = shift;
	my $srcgraph = shift;
	my $srckey = shift;
	my $tkey = shift;
	my $node = shift;
	my $parents = shift || {};

	# Find linked nodes
	my $nodes = find_linked_nodes($alignment, $node);

	# Find linked parents 
	foreach my $n (keys(%$nodes)) {
		my $nkey = substr($n, 0, 1);
		my $nid = substr($n, 1);
		if ($nkey eq $srckey) {
			my $snode = $srcgraph->node($nid);
			foreach my $edge (@{$snode->in()}) {
				if ($srcgraph->is_dependent($edge)) {
					find_linked_nodes($alignment, $nkey .  $edge->out(), 
						$parents);
				}
			}
		}
	}

	# If no target nodes among linked parents, take transitive parents
	if (! grep {$_ =~ /^$tkey/} keys(%$parents)) {
		foreach my $p (keys(%$parents)) {
			find_linked_parents($alignment, $srcgraph, $srckey, $tkey, $p, $parents);
		}
	}

	# Return linked parents
	return $parents;
}

sub find_linked_nodes {
	my $alignment = shift;
	my $node = shift;
	my $nodes = shift || {};

	# Return if node has been visited already
	return $nodes if ($nodes->{$node});
	$nodes->{$node} = 1;

	# Otherwise find all alignment edges linked to node
	foreach my $aedge (@{$alignment->node($node)}) {
		foreach my $n (@{$aedge->inArray()}) {
			find_linked_nodes($alignment, $aedge->inkey() . $n, $nodes);
		}
		foreach my $n (@{$aedge->outArray()}) {
			find_linked_nodes($alignment, $aedge->outkey() . $n, $nodes);
		}
	}

	# Return
	return $nodes;
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_alearn.pl
## ------------------------------------------------------------

sub cmd_alearn {
	my $self = shift;
	my $graph = shift;
	my $sublexfnames = shift;

	# Check that graph is an alignment
	if (! UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		error("current graph is not an alignment");
		return 1;
	}

	# Create new alignment lexicon
	my $alexicon = $graph->alexicon();
	if ($sublexfnames || ! $alexicon) {
		# Load sublexicons
		my $sublexicons = [];
		foreach my $fname (split(' ', $sublexfnames)) {
			my $sublexicon = DTAG::ALexicon->new();
			$sublexicon->load_alex($fname);
			push @$sublexicons, 
				$sublexicon;
		}

		# Create new alexicon and record it in graph
		$alexicon = DTAG::ALexicon->new();
		$alexicon->sublexicons($sublexicons);
		$graph->alexicon($alexicon);
	}

	# Train new lexicon
	$alexicon->untrain();
	$alexicon->train($graph);
	
	# Print learned lexicon
	#print $alexicon->write_alex();
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_align.pl
## ------------------------------------------------------------

my $node_check = 1;

sub cmd_align {
	my $self = shift;
	my $alignment = shift;
	my $from = shift;
	my $type = shift;
	my $to = shift;
	my $creator = shift || 0;
	my $node_check = defined($_[0]) ? shift : 1;
	my $lineno = shift || -1;

	# Find first two keys
	my ($key1, $key2) = sort(keys(%{$alignment->{'graphs'}}));

	# Create new alignment edge
	my $edge = AEdge->new();
	my ($outkey, $out) = parse_enodes($alignment, $from, $key1, $node_check);
	my ($inkey, $in) = parse_enodes($alignment, $to, $key2, $node_check);
	$edge->inkey($inkey);
	$edge->in($in);
	$edge->outkey($outkey);
	$edge->out($out);
	$edge->type($type || "");
	$edge->creator($creator);
	$edge->var("lineno", $lineno);
	
	# Add edge to alignment, if $edge is legal
	if (defined($inkey) && defined($outkey) && defined($out) && defined($in)) {
		$alignment->add_edge($edge);
	} else {
		error("illegal alignment edge specification");
	}

	# Return
	return 1;
}

sub parse_enodes {
	my $alignment = shift;
	my $enodes = shift;
	my $key = shift;
	my $node_check = shift;

	# Extract key
	if ($enodes =~ s/^([a-z])//) {
		$key = $1;

		# Fail if key does not exist
		if (! exists $alignment->{'graphs'}{$key}) {
			error("illegal alignment key $key");
			return (undef, undef);
		}
	}

	# Extract first node
	my @nodes = ();
	my $node1;
	if ($enodes =~ s/^(-?[0-9]+)//) {
		$node1 = check_node_rel($alignment, $key, $1, $node_check);
		push @nodes, $node1;
		return (undef, undef) if (! defined($node1));
	} else {
		return (undef, undef);
	}

	# Process remaining string
	while ($enodes) {
		if ($enodes =~ s/^\.\.([a-z])?(-?[0-9]+)//) {
			return (undef, undef) if (defined($1) && $1 ne $key);
			my $node2 = check_node_rel($alignment, $key, $2, $node_check);
			return (undef, undef) if (! defined($node2));
			for (my $i = $node1 + 1; $i <= $node2; ++$i) {
				push @nodes, $i
					if (defined(check_node($alignment, $key, $i, 0,
						$node_check)));
			}
			$node1 = $node2;
		} elsif ($enodes =~ s/^\+([a-z])?(-?[0-9]+)//) {
			return (undef, undef) if (defined($1) && $1 ne $key);
			$node1 = check_node_rel($alignment, $key, $2, $node_check);
			return (undef, undef) if (! defined($node1));
			push @nodes, $node1;
		} elsif ($enodes =~ s/^\s+//) {
		} else {
			error("ill-formed node range description from \"$enodes\"");
			return (undef, undef);
		}
	}

	# Return nodes and key
	return ($key, scalar(@nodes) == 1 ? $nodes[0] : [@nodes]);
}

sub check_node_rel {
	my $alignment = shift;
	my $key = shift;
	my $rel = shift;
	my $node_check = shift;

	my $node = check_node($alignment, $key, $alignment->rel2abs($key, $rel), 
		$node_check);

	# Check whether result is defined
	if (! defined($node)) {
		error("alignment edge refers to non-existent node $key$rel");
		return undef;
	}

	# Return node
	return $node;
}

sub check_node {
	my $alignment = shift;
	my $key = shift;
	my $node = shift;
	my $node_check = shift;

	# Return undef and print warning if node does not exist
	my $graph = $alignment->{'graphs'}->{$key};
	return undef  
		if (! $graph || ! $graph->node($node) 
			|| ($graph->node($node)->comment() && $node_check));

	# Return node
	return $node;
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_alignment.pl
## ------------------------------------------------------------

sub cmd_alignment {
	my $self = shift;
	my $fnames = shift;

	# Create new align object
	my $align = DTAG::Alignment->new($self);

	# Load files
	my $fnum = 97;
	foreach my $fname (split(' ', $fnames)) {
		print "alignment file " . chr($fnum) . ": $fname\n";
		$self->cmd_load($self->graph(), "", $fname);
		$align->add_graph(chr($fnum++), $self->graph());
	}

	# Add alignment to DTAG's list of graphs
	push @{$self->{'graphs'}}, $align;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# Update graph
	$self->cmd_return($align);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_aparse.pl
## ------------------------------------------------------------

# Specify tag feature
my $tag = "msd";

sub cmd_aparse {
	my $self = shift;
	my $graph = shift;
	my $afile = shift;
	my $scheme = shift;
	my $current_graph = $self->{'graph'};

	# Check scheme and correct scheme name
	if ($scheme =~ /^(da-en|da-es|da-it|da-de)$/) {
		$scheme =~ s/-/_/g;
		$scheme = "_" . $scheme;
	} else {
		error("unsupported scheme: $scheme\n");
		$scheme = "_da_en";
	}
	my $edgecmd = "process_edge$scheme";
	my $aedgecmd = "process_aedge$scheme";

	# Load alignment
	$graph->mtime(1);
	$self->cmd_load($graph, '-atag', $afile);
	my $alignment = $self->graph();

	# Check that alignment is loaded
	if (! UNIVERSAL::isa($alignment, 'DTAG::Alignment')) {
		error("invalid alignment graph: aborting aparse");
		return 1;
	}

	# Find source graph, source key, and target key
	my ($tkey, $skey, $source);
	my $graphfile = $graph->file();
	$graphfile =~ s/^.*\/([^\/]*)$/$1/g;
	foreach my $key (keys(%{$alignment->graphs()})) {
		my $keyfile = $alignment->graph($key)->file();
		$keyfile =~ s/^.*\/([^\/]*)$/$1/g;
		print "graph=$graphfile key=$keyfile\n";
		if ($graphfile eq $keyfile) {
			# Found target
			$tkey = $key;
		} else {
			# Found source
			$skey = $key;
			$source = $alignment->graph($skey);
		}
	}

	# Exit if source and target key not found
	if (! $skey || ! $tkey) {
		error("target graph does not match any graph in alignment");
		return 1;
	}
	print "source=". $source->file() . " target=" . $graph->file() . "\n";

	# Process all alignment edges
	foreach my $e (@{$alignment->edges()}) {	
		&{\&$aedgecmd}($e, $alignment, $skey, $tkey, $graph);
	}

	# Process all dependency edges in source
	$source->do_edges(\&$edgecmd, $alignment, $skey, $tkey, $graph);
	
	# Postprocess graph
	for (my $n = 0; $n < $graph->size(); ++$n) {
		post_process($graph, $n) if (! $graph->node($n)->comment());

	}

	# Calculate possible dependencies for node with no dependencies
	#for (my $n = 0; $n < $graph->size(); ++$n) {
	#	post_process_dlabels($graph, $alignment, $skey, $tkey, $n) 
	#		if (!  $graph->node($n)->comment());
	#}

	# Return to original graph
	$self->{'graph'} = $current_graph;
	$self->cmd_return();

	# Return
	return 1;
}

sub process_aedge {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Debug
	print "Language pair $skey-$tkey unsupported\n";
}

sub my_edge_add {
	my $graph = shift;
	my $edge = shift;
	my $style = shift;
	# $style = "blue" if (! defined($style));

	# Set edge style
	if ($style) {
		my $node = $graph->node($edge->in());
		$node->var('estyles', "$style:" . $edge->type()) if ($node);
	}

	# Add edge
	$graph->edge_add($edge)
		if ($edge->in() ne $edge->out());
}

sub process_edge {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	print "Language pair $skey-$tkey unsupported\n";
}

sub find_head {
	my $graph = shift;
	my $nodes = shift;

	# Find all dependents of all nodes
	my $hash = {};
	foreach my $n (@$nodes) {
		my $node = $graph->node($n);
		next() if (! $node);
		my $out = $node->out() || [];
		map {$hash->{$_->in()} = 1} @$out;
	}

	# Find all nodes in $nodes that are not dependents
	my @roots = grep {($hash->{$_} || 0) != 1} @$nodes;

	# Return head if unique
	return (scalar(@roots) == 1) ? $roots[0] : undef;
}


sub src2target {
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $snode = shift;

	my @tnodes = ();
	foreach my $aedge (grep {$_->type() ne "pnct"} @{$alignment->node($skey, $snode)}) {
		# Find source and target nodes
		my ($source, $target) = (undef, undef);
		if ($aedge->inkey() eq $tkey) {
			$source = $aedge->outArray();
			$target = $aedge->inArray();
		} elsif ($aedge->outkey() eq $tkey) {
			$source = $aedge->inArray();
			$target = $aedge->outArray();
		}

		# Save target nodes if $source and $target are defined
		if (defined($source) && defined($target)) {
			push @tnodes, @$target;
		}
	}

	# Return unique target node or undef
	return [@tnodes];
}

sub post_process {
	my $graph = shift;
	my $n = shift;
	my $node = $graph->node($n);

	# Return if node does not exist
	return if (! $node);

	# Return if node has a single governor
	my @govs = sort {$a->in() <=> $b->in()} 
		grep {$_->type !~ /\[/} @{$node->in()};
	return if (scalar(@govs) == 1);

	# Find dependent for unanalyzed comma
	my $maxloop = 50;
	if ($node->input() eq ",") {
		my $prev = $n - 1;
		while ($graph->node($prev) 
				&& scalar(@{$graph->node($prev)->in()})
				&& max($graph->node($prev)->in()->[0]->out(),
					map {$_->in()}
						@{$graph->node($prev)->out()}) < $n
				&& $maxloop) {
			$prev = $graph->node($prev)->in()->[0]->out();
			-- $maxloop;
		}
		if ($graph->node($prev) && ! $graph->node($prev)->comment()) {
			my_edge_add($graph, Edge->new($n, $prev, "pnct"));
		}
		return;
	}

	

	# Add filler subject to verbal complex
}

sub post_process_dlabels {
	my ($graph, $alignment, $skey, $tkey, $n) = @_; 
	
	# Find all siblings for this node
	my $tsibling = {};
	my $ssibling = {};
	foreach my $aedge (@{$alignment->node($tkey, $n)}) {
		map {$ssibling->{$_} = 1} @{$aedge->outArray()};
		map {$tsibling->{$_} = 1} @{$aedge->inArray()};
	}
	#$graph->node($n)->var('ssibling', join("|", sort(keys(%$ssibling))));
	#$graph->node($n)->var('tsibling', join("|", sort(keys(%$tsibling))));
	
	# Find edge types for all siblings in source graph
	my $sgraph = $alignment->graph($skey);
	my $sdeps = {};
	foreach my $snode (keys(%$ssibling)) {
		map {$sdeps->{$_->type()} = 1} @{$sgraph->node($snode)->in()};
	}
	$graph->node($n)->var('sdeps', join("|", sort(keys(%$sdeps))));

	# Find edge types for all siblings in target graph

	# Show set difference of edge types
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_as_example.pl
## ------------------------------------------------------------

sub cmd_as_example {
	my $self = shift;
	my $graph = shift;
	my $varspec = shift || "";
	my $rangespec = shift || "=0..=" . $graph->size();

	# Only applies to dependency graphs
	if (! $graph->isa("DTAG::Graph")) {
		error("current graph is not a dependency graph");
		return 1;
	}

	# Process range specification
	my $range = {};
	my $offset = $graph->offset();
	while ($rangespec ne "") {
		if ($rangespec =~ s/^\s*([-+=]?)([0-9]+)\.\.([-+=]?)([0-9]+)\b//) {
			my $i1 = ($1 eq "=") ? $2 : $offset + "$1$2";
			my $i2 = ($3 eq "=") ? $4 : $offset + "$3$4";
			for (my $i = $i1; $i <= $i2; ++$i) {
				$range->{$i} = 1
					if ($i >= 0 && $i < $graph->size() 
						&& ! $graph->node($i)->comment())
			}
		} elsif ($rangespec =~ s/^\s*([-+=]?)([0-9]+)\b//) {
			my $i = ($1 eq "=") ? $2 : $offset + $2;
			$range->{$i} = 1
				if ($i >= 0 && $i < $graph->size() 
					&& ! $graph->node($i)->comment())
		} else {
			$rangespec =~ s/^\s+//g;
			$rangespec =~ s/^\S+//g;
		}
	}

	# Number nodes
	my $nodes = {};
	my $nodecnt = 0;
	foreach my $i (sort {$a <=> $b} keys(%$range)) {
		$nodes->{$i} = ++$nodecnt;
	}

	# Process nodes and in-edges
	my $s = "";
	my @vars = split(/\|/, $varspec);
	foreach my $i (sort {$a <=> $b} keys(%$range)) {
		# Process features
		my $node = $graph->node($i);
		if (! $node->comment()) {
			my @strings = ($node->input());
			foreach my $var (@vars) {
				push @strings, $node->svar($var);
			}
			$s .= join("|", @strings);

			# Process in-edges
			my @edges = ();
			foreach my $e (@{$node->in()}) {
				my $out = $nodes->{$e->out()};
				my $type = $e->type();
				push @edges, "$out:$type"
					if ($out);
			}
			$s .= "<" . join(",", @edges) . ">"
				if (@edges);
		}
		$s .= " ";
	}

	# Process inalignments
	my @alignments = sort {map_num($a) <=> map_num($b)}
		keys(%{$graph->var("inalign")});
	foreach my $align (@alignments) {
		my ($in, $out, $label) = split(/\s+/, $align);
		my $mapin = map_inalign($in, $nodes);
		my $mapout = map_inalign($out, $nodes);
		if (defined($mapin) && defined($mapout)) {
			$s .= "@" . $label . "($mapin,$mapout) ";
		}
	}

	# Print string
	print "\n" . $s . "\n\n";
}

sub map_inalign {
	my $spec = shift;
	my $nodes = shift;
	my $mapped = "";
	while (length($spec) > 0) {
		if ($spec =~ s/^([0-9]+)//) {
			my $mapnode = $nodes->{$1};
			return undef if (! defined($mapnode));
			$mapped .= $mapnode;
		} else {
			$spec =~ s/^([^0-9]+)//;
			$mapped .= $1;
		}
	}
	return $mapped;
}

sub map_num {
	my $s = shift;
	$s =~ /^([0-9]+)/;
	return $1 || 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_autoalign.pl
## ------------------------------------------------------------

sub cmd_autoalign {
	my $self = shift;
	my $graph = shift;
	my $files = shift || "";
	
	# Check that $graph is an Alignment
	if (! UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		error("no active alignment");
		return 1;
	}

	# Turn off autoaligner if argument is "-off"
	if ($files =~ /^\s*-off\s*$/) {
		$graph->var('autoalign', 0);
		$self->cmd_return();
		return 1;
	}

	# If first file argument is "-default" and an alexicon already
	# exists, then drop given files
	$files = ""
		if ($files =~ /^\s*-default\s+/ 
			&& ($graph->alexicon() || $self->var('alexicon')));

	# Save current graph
	my $currentgraph = $self->{'graph'};
	$graph->mtime(1);

	# Create new alignment lexicon
	my $alexicon = $graph->alexicon();
	my $viewer = $self->var('viewer');
	$self->var('viewer', 0);
	if ($files) {
		$alexicon = DTAG::ALexicon->new();
		$graph->alexicon($alexicon);
		$self->var('alexicon', $alexicon);
		foreach my $file (glob($files)) {
			# Load file
			if ($file =~ /.alex$/) {
				# Alignment lexicon
				my $sublexicon = $alexicon->new_sublexicon();
				$sublexicon->load_alex($file);
			} elsif ($file =~ /.atag$/) {
				# Alignment: load alignment
				$self->cmd_load($graph, '-atag', $file);
				my $alignment = $self->graph();
				$self->{'graph'} = $currentgraph;

				# Train new lexicon for alignment
				#my $sublexicon = $alexicon->new_sublexicon();
				#$sublexicon->train($alignment);
				$alexicon->train($alignment);
			}
		}
	} elsif ($graph->alexicon()) {
		# Use previous alignment lexicon
		$alexicon = $graph->alexicon();
		$graph->alexicon($alexicon);
		inform("Using previous alignment lexicon");
	} elsif ($self->var('alexicon')) {
		# Use previous alignment lexicon
		$alexicon = $self->var('alexicon');
		$graph->alexicon($alexicon);
		inform("Using previous alignment lexicon");
	} else {
		error("No alignment lexicon specified");
		return 1;
	}

	# Autoalign edges
	$graph->auto_offset();
	$alexicon->autoalign($graph);
	$self->var('viewer', $viewer);

	# Update graph
	$self->cmd_return();

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_autoevaluate.pl
## ------------------------------------------------------------

sub cmd_autoevaluate {
	my $self = shift;
	my $graph = shift;
	my $atagfile = shift;

	if (UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		# Check that there is an active alignment lexicon
		if (! $graph->alexicon()) {
			error("no current alignment lexicon");
			return 1;
		}

		# Load new alignment file if it exists
		my $copy;
		if ($atagfile) {
			print "Using template $atagfile\n";
			$self->cmd_load_atag($graph, $atagfile);
			$copy = $self->graph();
		}

		# Call autoevaluate on alignment lexicon
		$copy = $graph->alexicon()->autoevaluate($graph, $copy);
		push @{$self->{'graphs'}}, $copy;
    	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	    # Update graph
	    $self->cmd_return($copy);
		return 1;
	} else {
		error("DTAG graphs do not support autoevaluation");
		return 1;
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_autogloss.pl
## ------------------------------------------------------------

# Specify tag feature

sub cmd_autogloss {
	my $self = shift;
	my $graph = shift;
	my $afile = shift || "";
	my $mapfiles = shift || "";

	# Create atag graph, either dummy or loaded graph
	my $agraph = DTAG::Alignment->new($self);
	my $key = "";
	my $ograph = undef;
	if ($afile) {
		# Load atag file
		$self->cmd_load_atag($graph, $afile);
		$agraph = $self->graph();

		# Determine key
		foreach my $k (keys(%{$agraph->graphs()})) {
			if ($agraph->graph($k)->file() eq $graph->file()) {
				$key = $k;
			} else {
				$ograph = $agraph->graph($k);
			}
		}


		# Determine whether graph was found in alignment
		if (! $key) {
			return error("Graph not found in alignment");
		}
	}

	# Load all other gloss maps
	my $maps = [];
	foreach my $mapfile (split(/\s+/, $mapfiles)) {
		if (-f $mapfile) {
			my $map = {};
			push @$maps, $map;
			open(IFS, "<$mapfile") 
				|| return error("Error opening mapfile $mapfile");
			while (my $line = <IFS>) {
				chomp($line);
				my ($key, $value) = split(/\t/, $line);
				$map->{$key} = $value;
			}
			close(IFS);
		} else {
			return error("Non-existent mapfile $mapfile!");
		}
	}

	# Process all nodes in graph
	for (my $i = 0; $i < $graph->size(); ++$i) {
		my $N = $graph->node($i);
		my $gloss = "";
		if (! $N->comment()) {
			# Lookup gloss in alignment
			my @aedges = grep {$_->type() eq "" && $_->inkey() ne $_->outkey()} 
				@{$agraph->node($key, $i) || []};
			if (@aedges) {
				if ($aedges[0]->outkey() eq $key
					&& scalar(@{$aedges[0]->outArray()}) == 1) {
					$gloss = join("_", 
						map {($ograph->node($_) ? $ograph->node($_)->input() : "") 
							|| ""}
							@{$aedges[0]->inArray()});
				} elsif ($aedges[0]->inkey() eq $key &&
						scalar(@{$aedges[0]->inArray()}) == 1) {
					$gloss = join("_", 
						map {($ograph->node($_) ? $ograph->node($_)->input()
							: "") 
							|| ""}
							@{$aedges[0]->outArray()});
				}
			}

			# Alternatively, lookup gloss in map files (first match
			# is used)
			my $word = $N->input();
			my $lcword = lc($word);
			my $lemma = $N->var('lemma') || undef;
			if (! $gloss) {
				foreach my $token ($word, $lcword, $lemma) {
					foreach my $map (@$maps) {
						if ($map->{$token}) {
							$gloss = $map->{$token};
							last();
						}
					}
					last() if ($gloss);
				}
			}

			# Alternatively, use source string
			$gloss = $word if (! $gloss);

			# Save gloss in tag file
			$gloss =~ s/ /_/g;
			$gloss =~ s/"/&quot;/g;
			$N->var('gloss', $gloss);
		}
	}
	push @{$self->{'graphs'}}, $graph;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	$self->cmd_vars($graph, 'gloss');

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_autoreplace.pl
## ------------------------------------------------------------

sub cmd_autoreplace {
	my $self = shift;
	my $graph = shift;
	my $corpus = shift || "";
	my @relations = split(/\s+/, shift);

	# Check arguments
	if (scalar(@relations) == 0) {
		error('Usage: autoreplace [-corpus] $relation1 $relation2 ...');
		return 1;
	}

	# Execute find query
	my $erel = "/^(" . join("|", @relations) . ')$/';
	$erel = $relations[0] if ($#relations == 0);
	my $query = "$corpus\$dep $erel \$gov";
	print "query=\"$query\"\n";
	$self->cmd_find($graph, $query);

	# Create edge type hash
	my $relhash = {};
	map {$relhash->{$_} = 1} @relations;

	# Process matches
	my $matches = $self->{'matches'};
	$self->{'replace_files'} = ['', sort(keys(%$matches))];
	$self->{'replace_matches'} = [''];
	$self->{'replace_hash'} = $relhash;
	$self->{'replace_times'} = [];
	$self->cmd_replace($graph);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_autotag.pl
## ------------------------------------------------------------

sub cmd_autotag {
	my $self = shift;
	my $graph = shift;
	my $tag = shift;
	my $files = shift || "";
	my $matches = shift || 0;
	#print "autotag: tag=\"$tag\" matches=\"$matches\" files=\"$files\"\n";
	
	# Check that $graph is a dependency graph
	if (! UNIVERSAL::isa($graph, 'DTAG::Graph')) {
		error("no active graph");
		return 1;
	}

	# Turn off autotagger if argument is "-off"
	if ($files =~ /^\s*-off\s*$/) {
		$graph->var('autotagvar', undef);
		return 1;
	} else {
		$graph->var('autotagvar', $tag);
	}

	# Specify matches
	$graph->var('autotagmatches', 
		$matches ? $graph->matches($self) : undef);

	# Set new variable
	$self->cmd_vars($graph, $tag);

	# If first file argument is "-default" and an autotag lexicon already
	# exists, then drop given files
	my $lexicons = $self->var('autotaglex') || {};
	$self->var('autotaglex', $lexicons);
	if (! ($files =~ /^\s*-default\s+/ && defined($lexicons->{$tag}))) {
		$lexicons->{$tag} = $lexicons->{$tag} || {};
		my $lexicon = {};
		$lexicons->{$tag} = $lexicon;

		# Save current graph and viewer
		my $currentgraph = $self->{'graph'};
		$graph->mtime(1);
		my $viewer = $self->var('viewer');
		$self->var('viewer', 0);

		# Create new tag lexicon
		inform("Training autotagger. Please wait.");
		foreach my $file (glob($files)) {
			# Load file
			if ($file =~ /.tag$/) {
				# Graph
				$self->cmd_load_tag($graph, $file);
				my $ngraph = $self->graph();
				$self->{'graph'} = $currentgraph;

				# Train new lexicon for alignment
				for (my $i = 0; $i < $ngraph->size(); ++$i) {
					my $node = $ngraph->node($i);
					my $tagvalue = $node->var($tag);
					$self->cmd_autotag_addkeys($node->input(),
						$tagvalue, $tag, $lexicon);

					my $key = $node->input();
					if (defined($key) && defined($tagvalue)) {
						if (! exists $lexicon->{$key}) {
							$lexicon->{$key} = {};
						}
						$lexicon->{$key}{$tagvalue} += 1;
					}
				}
			}
		}
	}
	
	# Find last tagged position
	my $pos = -1;
	for (my $i = $graph->size() - 1; $i >= 0; --$i) {
		my $node = $graph->node($i);
		if (defined($node->var($tag))) {
			$pos = $i + 1;
			last;
		}
	}

	# Print help
	print "Autotagging commands:\n";
	print "    \"<\$label\": set label for current word with replacement of #\$n shortcuts\n";
	print "    \"\$pos<\$label\": set label for word \$pos with replacement of #\$n shortcuts\n";
	print "    \"autotag -off\": stop autotagger\n";
	print "    \"autotag -pos \$pos\": move to word \$pos\n";
	print "    \"autotag -offset \$pos\": set offset to \$pos\n";

	# Autotag edges
	$graph->var('autotagpos', $pos - 1);
	$self->var('viewer', $viewer);
	$self->cmd_autotag_next($graph);

	# Return
	return 1;
}

sub cmd_autotag_addkey {
	my ($self, $key, $value, $lexicon) = @_;
	if (defined($key) && defined($value)) {
		if (! exists $lexicon->{$key}) {
			$lexicon->{$key} = {};
		}
		$lexicon->{$key}{$value} += 1;
	}
}	


sub cmd_autotag_addkeys {
	my ($self, $key, $value, $feature, $lexicon) = @_;
	$lexicon = $self->var('autotaglex')->{$feature}
		if (! defined($lexicon));
	$self->cmd_autotag_addkey($key, $value, $lexicon);
	$self->cmd_autotag_addkey("_lc_:" . lc($key), $value, $lexicon);
}	

sub cmd_autotag_lookup {
	# Parameters
	my ($self, $key, $feature, $lexicon) = @_;
	$lexicon = $self->var('autotaglex')->{$feature}
		if (! defined($lexicon));

	# Lookup
	my $matches = {};
	my $hashes = [$lexicon->{$key}, $lexicon->{"_lc_:" . lc($key)}];
	foreach my $hash (@$hashes) {
		if (defined($hash)) {
			foreach my $key (keys(%$hash)) {
				$matches->{$key} += $hash->{$key};
			}
		}
	}

	# Return matches
	return($matches);
}

sub autotag_off {
	my ($self, $graph) = @_;
	$graph->var('autotagvar', undef);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_autotag_next.pl
## ------------------------------------------------------------

sub cmd_autotag_next {
	my $self = shift;
	my $graph = shift;
	my $value = shift;

	# Find autotag variable
	my $var = $graph->var('autotagvar');
	if (! defined($var)) {
		error("Autotagging is turned off. Please use \"autotag \$var \$files\" to turn it on");
		return;
	}

	# Set current value if value is defined
	my $node;
	my $pos = $graph->var('autotagpos');
	if (defined($value)) {
		# Find current position
		$node = $graph->node($pos);

		# Determine if user specified value or value id
		if (defined($node)) {
			# Process shortcuts
			if ($value =~ /\#/) {
				my $shortcuts = $graph->var('autotagshortcuts');
				for (my $i = 0; $i <= $#$shortcuts; ++$i) {
					my $shortcut = $shortcuts->[$i];
					$value =~ s/\#$i(?![0-9])/$shortcut/g;
				}
			} 

			# Set new value
			if (defined($value)) {
				$node->var($var, $value);
				$self->cmd_autotag_addkeys($node->input(), $value, $var); 
			}
		}
	}

	# Find next untagged node
	my $matches = $graph->var('autotagmatches');
	for (my $i = $pos + 1; $i < $graph->size(); ++$i) {
		$node = $graph->node($i);
		if (defined($node) && ! $node->comment()
			&& (! defined($matches) || $matches->{$i})) {
			$pos = $i;
			last;
		}
	}

	# Exit if we reached end of graph
	if ($pos >= $graph->size() || ! defined($node)) {
		inform("Autotagger reached end of graph");
		return;
	}

	# Save position	
	$graph->var('autotagpos', $pos);
	
	# Lookup word in lexicon, and add in most frequent first order
	my $shortcuts = [];
	my $hash = $self->cmd_autotag_lookup($node->input(), $var);
	my $hicount = 0;
	foreach my $value (sort {$hash->{$b} <=> $hash->{$a}} keys(%$hash)) {
		$hicount = $hash->{$value}
			if ($hash->{$value} > $hicount);
		if ($hash->{$value} > $hicount / 20 && $#$shortcuts < 15) {
			push @$shortcuts, $value
				if (! grep {$value eq $_} @$shortcuts);
		}
	}

	# Find default shortcut (lemma or input by default)
	my $defaultshortcutfield = $graph->var('autotagshortcut_default') ||
		["lemma", "_input"];
	foreach my $field (@$defaultshortcutfield) {
		my $value = ($field eq "_input") ? $node->input() : $node->var($field);
		if (defined($value)) {
			push @$shortcuts, $value
				if (! grep {$value eq $_} @$shortcuts);
			last;
		}
	}

	# Left and right context parameters
	my $wordsep = "\n       ";
	my $maxchars = 60;
	my $maxcount = 5;

	# Find left and right context
	my $lcontext = [];
	for (my $i = $pos - 1; $i >= 0 && scalar(@$lcontext) < $maxcount; --$i) {
		if (! $graph->node($i)->comment()) {
			unshift @$lcontext, $i;
		}
	}

	# Find right context
	my $rcontext = [];
	for (my $i = $pos + 1; $i < $graph->size() 
			&& scalar(@$rcontext) < $maxcount; ++$i) {
		my $node = $graph->node($i);
	    if (defined($node) && ! $graph->node($i)->comment()) {
			push @$rcontext, $i;
		}
	}

	# Print out context
	foreach my $cpos (@$lcontext, $pos, @$rcontext) {
		autotag_next_print_node($graph, $cpos, $var, 
			($cpos == $pos) ? "*" : " ");
	}

	# Print out shortcuts
	$graph->var('autotagshortcuts', $shortcuts);
	for (my $i = 0; $i <= $#$shortcuts; ++$i) {
		print "#$i: " . $shortcuts->[$i] . "\n";
	}
}

sub autotag_next_print_node {
	my ($graph, $pos, $var, $mark) = @_;
	my $offset = $graph->offset();
	my $node = $graph->node($pos);
	printf("%1s % 5s: %-20s %s\n", 
		$mark, 
		($offset > 0 && $pos >= $offset ?  "+" : "") . ($pos - $offset),
		$node->input() || "", $var . "=" . ($node->var($var) || ""));
}

sub autotag_setpos {
	my ($self, $graph, $pos, $prev) = @_;
	my $offset = $graph->offset();
	$pos = $offset + $pos;
	$graph->var('autotagpos', $prev ? $pos - 1 : $pos);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_cd.pl
## ------------------------------------------------------------

sub cmd_cd {
	my $self = shift;
	my $dir = (shift) || "";

	# Change to new directory
	my $HOME = $ENV{'HOME'} || ".";
	$dir =~ s/~/$ENV{'HOME'}/g;
	chdir($dir);
	$self->cmd_shell("pwd");

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_clear.pl
## ------------------------------------------------------------

sub cmd_clear {
	my $self = shift;
	my $graph = shift;
	my $type = shift || '-tag';

	if ($type eq '-lex') {
		my $lexicon = $self->lexicon();
		return 1 if (! $lexicon);
		$lexicon->clear();
	} elsif ($type eq '-edges') {
		if (UNIVERSAL::isa($graph, 'DTAG::Graph')) {
			$graph->clear_edges();
		} elsif (UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
			$graph->erase_all();
		}
	} else {
		if (UNIVERSAL::isa($graph, 'DTAG::Graph')) {
			$graph->clear();
			$graph->file('');
			$self->cmd_return($graph);
		} elsif (UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
			$graph->erase_all();
			$graph->file('');
			$self->cmd_return($graph);
		}
	} 

	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_close.pl
## ------------------------------------------------------------

sub cmd_close {
	my $self = shift;
	my $graph = shift;
	my $options = shift || "";

	# Close graph
	if ($graph) {
		# Clear graph and remove it from graph list
		$self->{'graphs'} = [grep {$_ ne $graph} @{$self->{'graphs'}}];

		# Clear all unmodified graphs
		$self->{'graphs'} = [grep {$_->mtime()} @{$self->{'graphs'}}]
			if ($options =~ /-all/);

		# Open new graph, if graph list is empty
		if (! @{$self->{'graphs'}}) {
			my $new = DTAG::Graph->new($self);
			push @{$self->{'graphs'}}, $new;
		}

		# Check that current graph is legal
		if (($self->{'graph'} || 0) >= scalar(@{$self->{'graphs'}})) {
			$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
		}

		# Update current graph
		$self->cmd_return($self->graph());
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_cmdlog.pl
## ------------------------------------------------------------

sub cmd_cmdlog {
	my $self = shift;
	my $file = shift;

	# Insert user name
	my $user = $self->var("user") || "none";
	if ($file =~ /{USER}/) {
		$file =~ s/{USER}/$user/g;
	}
	my $HOME = $ENV{'HOME'};
	$file =~ s/\s*\~\//$HOME\//g;

	# Open file for appending
	my $fh;
	my $date = `date +'%Y.%m.%d-%H.%M'` || "???";
	chomp($date);
	$file = $file . "-$date";
	if (open($fh, ">>", $file)) {
		autoflush $fh 1;
		$self->var("cmdlog", $fh);
		$self->var("cmdlog.time0", time());
		print $fh "# open cmdlog: $date\n";
		return 1;
	}

	error("Cannot open file $file for appending");
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_comment.pl
## ------------------------------------------------------------

sub cmd_comment {
	my $self = shift;
	my $graph = shift;
	my $posr = shift;
	my $comment = shift;

	# Check range
	my $pos = (! defined($posr) || $posr eq "") 
		? $graph->size()
		:  ($posr || 0) + $graph->offset(); 

	# Create new node
	my $N = Node->new();
	$N->input($comment);
	$N->comment(1);

	# Add new node to graph, and mark graph as modified
	$graph->node_add($pos, $N);

	# Mark graph as modified
	$graph->mtime(1);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_compound.pl
## ------------------------------------------------------------

sub cmd_compound {
	my $self = shift;
	my $graph = shift;
	my $key = shift || "";
	my $noder = shift;
	my $compound = shift || "";
	my $ocompound = $compound . "";
	$compound =~ s/^\s+//g;

	# Autoformat compound
	$compound = compound_autonumber($compound);

	# Now we have the renumbered segment
	my $cmd = "";
	if (UNIVERSAL::isa($graph, 'DTAG::Graph') && (! $key)) {
		# Dependency graph
		my $node = defined($noder) ? $noder + $graph->offset() : undef;
		my $N = $graph->node($node);
		if ($compound) {
			$N->var('compound', $compound);
			$graph->vars()->{'compound'} = 1;
		}
		
		# Errors: non-existent node, or comment node
		return error("Non-existent node: $noder") if (! $N);
		return error("Node $noder is a comment node.") if ($N->comment());
		my $default = $N->input();
		if ($ocompound && ($compound eq "")) {
			$N->var('compound', '');
		}

		# Mark graph as modified and add existing compound
		$compound = $N->var('compound') || $N->input();
		$cmd = "segment $noder $compound";
		print "segment $key$noder $compound\n";
	} elsif (UNIVERSAL::isa($graph, 'DTAG::Alignment') && ($key)) {
		# Alignment: check that key is valid
		my $ngraph = $graph->graph($key);
		return error("Non-existent graph key \"$key\"") if (!  $ngraph);

		# Check that node is valid
		my $nodeabs = $noder + ($graph->offset($key) || 0);
		my $node = $ngraph->node($nodeabs);
		return error("Non-existent node \"$key$noder\"") if (! $node);

		# Retrieve compound from graph, if non-existent
		my $compounds = $graph->{'compounds'};
		my $default = $node->var('compound') || $node->input() || "";
		if (! $compound) {
			$compound = $compounds->{$key . $nodeabs} || $default;
			$compound = $default if ($ocompound =~ /^\s+$/);
		}

		# Remove compound if equal to graph compound or input
		if ($ocompound && ($compound eq $default)) {
			delete $compounds->{$key . $nodeabs};
		} else {
			$compounds->{$key . $nodeabs} = $compound;
		}

		# Mark graph as modified and add existing compound
		$cmd = "segment $key$noder $compound";
		print "segment $key$noder=$compound\n";
	}

	# Update command line history and graph
	if (! $ocompound) {
		$self->nextcmd($cmd);
	} else {
		 $self->term()->addhistory($cmd);
	}
	$graph->mtime(1);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_confusion.pl
## ------------------------------------------------------------

sub cmd_confusion {
	my ($self, $relset, $files, $add) = @_;
	my $confusions = $self->{'confusion'} = $self->{'confusion'} || {};

	# Initialize confusion tables
	my $confusion = $add ? ($self->{'confusion'}{$relset} || {}) : {};
	$confusions->{$relset} = $confusion;

	# Logging
	inform("Reading \"$relset\" confusion table from: $files");

	# Open files
	foreach my $file (split(/\s+/, $files)) {
		# Open confusion file (format: $rel $count $x%=$rel\t...)
		$file =~ s/^~/$ENV{HOME}/g;
		if (!  open(CONF, "<:encoding(utf8)", $file)) {
			warning("Cannot open file $file for reading\n");
			next;
		}

		# Read file
		my $relsethash = $self->{'relsets'}{$relset} || {};
		while (my $line = <CONF>) {
			chomp($line);
			my @fields = map {
				my $crel = $_; 
				my $rellist = $relsethash->{$crel};
				$rellist ? $rellist->[$REL_SNAME] : $crel;
			} split(/\t/, $line);
			my $rel = shift(@fields);
			$confusion->{$rel} = [@fields]
				if (defined($rel) && $rel ne "");
		}

		# Close file
		close(CONF);
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_corpus.pl
## ------------------------------------------------------------

sub cmd_corpus {
	my $self = shift;
	my $cmd = shift || "";

	# Update corpus files, if $cmd is specified
	if ($cmd !~ /^\s*$/) {
		# Save glob
		$self->{'corpus_glob'} = $cmd;

		# Find list of globs
		my @globs = split(/\s+/, $cmd);
		my @files = ();

		# Expand globs
		while (@globs) {
			push @files, glob(shift(@globs));
		}

		# Filter out unreadable files and save them
		@files = grep { -r $_ } @files;
		$self->{'corpus'} = \@files;
	}

	# Print files
	$self->print("corpus", "info", 
		"corpus files =" . ($self->{'corpus_glob'} || "") . "\n");

	# Return
	return 1;
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_corpus_apply.pl
## ------------------------------------------------------------

sub cmd_corpus_apply {
	my $self = shift;
	my $cmd = shift || "";
	my $graph = $self->graph();

	# Process options
	my $time = - time();
	my $progress = "";

	# Solve DNF-query for all files in corpus
	my $iostatus = $|; $| = 1; my $c = 0;
	my $findfiles = $self->{'corpus'};
	my $laststatus = time() - 1;
	foreach my $f (@$findfiles) {
		# Load new file from corpus, if this is a corpus search 
		$self->cmd_load($graph, undef, $f);
		$graph = $self->graph();
		$self->do($cmd);

		# Print progress report 
		if (! $self->quiet()) {
	 		if (time() > $laststatus + 0.5 ) {
				$laststatus = time();
				my $blank = "\b" x length($progress);
				my $percent = int(100 * $c / (1 + $#$findfiles));
				$progress = 
					sprintf('Processed %02i%%. Elapsed: %s. ETA: %s.',
					$percent,
					seconds2hhmmss(time()+$time),
					seconds2hhmmss(int((100-$percent) 
							/ ($percent || 1) * (time()+$time))));
				$self->print("corpus-apply", "status", $blank . $progress);
			}
			++$c;
		}

		# Abort on request
		last() if ($self->abort());
	}
	print "\b" x length($progress)
		. " " x length($progress) 
		. "\b" x length($progress)
			if (! $self->quiet());
	$| = $iostatus;

    # Print search statistics
	$time += time();
	print "corpus-apply took " . seconds2hhmmss($time) 
		. " seconds to execute \"$cmd\".\n" if (! $self->quiet());

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_del.pl
## ------------------------------------------------------------

sub cmd_del {
	my $self = shift;
	my $graph = shift;
	my $nodeinr = shift;
	my $etype = shift;
	my $nodeoutr = shift;
	my $called_as_edel = shift;

	# Check that nodeblocking is not activated
	if ($graph->{'block_nodedel'} && ! $called_as_edel) {
		print "WARNING: Node deletion turned off: no edges deleted\n";
		print "Please use \"edel <node>\" or \"edel <node> <label> <node>\"\n";
		print "when deleting in-edges. Node deletion can be turned on/off\n";
		print "with \"del -on\" / \"del -off\"\n";
		return 1;
		#$self->cmd_edel($graph, $nodeinr);
	}

	# Delete range if relevant
	if ($nodeinr =~ /^([+-]?[0-9]+)\.\.([+-]?[0-9]+)/) {
		my $first = $1;
		my $last = $2;
		if ($first < $last) {
			for (my $i = $last; $i >= $first; --$i) {
				$self->cmd_del($graph, $i);
			}
		}
		return 1;
	}


	# Apply offset
	my $nodein = defined($nodeinr) ? $nodeinr + $graph->offset() : undef;
	my $nodeout = defined($nodeoutr) ? $nodeoutr + $graph->offset() : undef;

	# Check that $nodein is valid
	my $nin  = $graph->node($nodein);
	my $nout = $graph->node($nodeout);
	return error("Non-existent node: $nodeinr") 
		if ((! defined($nodein)) || (! ref($nin)));

	# Delete in-edges in $nodein (and out-edges, if $nodein is deleted)
	my @edges = defined($etype) 
		? @{$nin->in()} 
		: (@{$nin->in()}, @{$nin->out()});
	foreach my $e (@edges) {
		# Delete edge if it matches description
		if (($e->in() == $nodein || ($e->out() == $nodein)) && 
			((! defined($etype)) 
				|| (($e->type() eq $etype)
					&& ($e->out() == $nodeout)))) {
			$graph->edge_del($e) 
		}
	}

	# Delete node, if requested
	if ((! $graph->{'block_nodedel'}) && ! defined($etype)) {
		# Delete node
		splice(@{$graph->nodes()}, $nodein, 1);
		my $id = $nin->var("id");
		$graph->compile_ids();

		# Update edges in nodes at or after $nodein
		for (my $i = $nodein; $i < $graph->size(); ++$i) {
			my $n = $graph->node($i);

			# Process in-edges
			foreach my $e (@{$n->in()}) {
				if ($e->in() > $e->out()) {
					$e->in($e->in() - 1);
					$e->out($e->out() - 1) if ($e->out() >= $nodein);
				}
			}

			# Process out-edges
			foreach my $e (@{$n->out()}) {
				if ($e->out() > $e->in()) {
					$e->out($e->out() - 1);
					$e->in($e->in() - 1) if ($e->in() >= $nodein);
				}
			}
		}
	}

	# Mark graph as modified
    $graph->mtime(1);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_del_align.pl
## ------------------------------------------------------------

sub cmd_del_align {
	my $self = shift;
	my $graph = shift;
	my $ref = shift;

	# Check that $graph is an alignment
	if (ref($graph) ne "DTAG::Alignment") {
		error("current graph is not an alignment!");
		return 1;
	}

	# Delete edge with node
	$graph->del_node($ref);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_diff.pl
## ------------------------------------------------------------

sub cmd_diff {
	my $self = shift;
	my $graph = shift;
	my $file = shift || $graph->{'diff_file'};

	# Get position subroutine
	my $pos = $graph->layout($self, 'pos') || sub {return 0};

	# Set diff file in graph
	$graph->{'diff_file'} = $file;

	# Load file with comparison analysis (using a few tricks to avoid
	# closing $graph)
	my $graphid = $self->{'graph'};
	$self->cmd_load(DTAG::Graph->new($self), undef, $file);
	my $graph2 = pop(@{$self->{'graphs'}});
	$self->{'graph'} = $graphid;

	# Delete all in-edges marked as 'diff' in $graph
	$graph->do_edges(
		sub {
			$_[1]->edge_del($_[0]) 
				if ($_[0]->var('diff'));
		},
		$graph);

	# Add edges in $graph2 to $graph
	$graph2->do_edges(
		sub {
			$_[0]->var('diff', 1);
			$_[0]->var('ignore', 1);
			$_[1]->edge_add($_[0]);
		},
		$graph);

	# Issue style commands
	$self->do('style plus -graph -arclabel -color red -arc -color red');
	$self->do('style minus -graph -arclabel -color red -arc -color red');
	$self->do('layout -graph -pos $e->var("diff")');
	$self->do('layout -graph -estyles [$G->diffplus($e) ? "plus" : 0, $G->diffminus($e) ? "minus" : 0]');

	my ($proposed50, $correct50) = (0,0);
	my $labels50 = {};

	# Compare graphs and print precision and recall
	if (! $self->quiet()) {
		my $stats = $self->compare_graphs($graph, $pos);

		# Print file names
		printf "gold-standard=%s\ndiff-file=%s\n",
			$graph->file(), $graph2->file();
		my $printf = "%-8s%8s%9s%8s%10s%10s%12s\n";
		printf $printf,
			"LABEL", "GOLD", "PROPOSED", "CORRECT", "PRECISION", "RECALL", "F-SCORE";
		printf $printf,
			"", "A1", "A2", "AGREED", "", "", "AGREEMENT";
		my $sep = sprintf $printf,
			"-----", "----", "--------", "-------", "---------", "------", "---------";
		print $sep;

		# Print statistics 
		my $print_total = 0;
		my $print_total1 = 0;
		foreach my $label ((sort {(($stats->{$b}[0]||0)+($stats->{$b}[1]||0))
		                <=> (($stats->{$a}[0]||0) + ($stats->{$a}[1]||0))
			|| $a cmp $b} keys(%$stats)), 'TOTAL', 'TOTAL1') {
			# Skip TOTAL the first time
			if ($label eq 'TOTAL') {
				if ($print_total) {
					print $sep;
				} else {
					$print_total = 1;
					next();
				}
			} elsif ($label eq 'TOTAL1') {
				if (! $print_total1) {
					$print_total1 = 1;
					next();
				}
			}
			
			# Find counts
			my ($total, $proposed, $correct, $correct_unlbl) = 
				($stats->{$label}[0] || 0, $stats->{$label}[1] || 0,
				$stats->{$label}[2] || 0, $stats->{$label}[3] || 0);
			
			# Print counts
			printf $printf,
				$label,
				$total, $proposed, $correct, 
				sprintf("%.1f", 100 * $correct / max(1, $proposed)), 
				sprintf("%.1f", 100 * $correct / max(1, $total)), 
				sprintf("%.1f", 200 * ($correct / max(1, $proposed)) 
					* ($correct / max(1, $total)) 
					/ max(0.00001, ($correct / max(1, $proposed) 
							+ $correct / max(1, $total))));

			# Calculate precision>0.5 totals
			if ($correct / max(1, $proposed) > 0.5 && $label !~ /^TOTAL/ && $total >= 5) {
				$correct50 += $correct;
				$proposed50 += $proposed;
				$labels50->{$label} = 1;
			}
		}

		# Print unlabelled total scores
		my ($total, $proposed, $correct, $correct_unlbl) = 
			($stats->{'TOTAL'}[0] || 0, $stats->{'TOTAL'}[1] || 0,
			$stats->{'TOTAL'}[2] || 0, $stats->{'TOTAL'}[3] || 0);
		printf $printf,
			"nolabel",
			$total, $proposed, $correct_unlbl, 
			sprintf("%.1f", 100 * $correct_unlbl / max(1, $proposed)), 
			sprintf("%.1f", 100 * $correct_unlbl / max(1, $total)), 
			sprintf("%.1f", 200 * ($correct_unlbl / max(1, $proposed)) 
				* ($correct_unlbl / max(1, $total)) 
				/ max(0.00001, ($correct_unlbl / max(1, $proposed) 
						+ $correct_unlbl / max(1, $total))));

		# Print unlabelled total primary scores
		($total, $proposed, $correct, $correct_unlbl) = 
			($stats->{'TOTAL1'}[0] || 0, $stats->{'TOTAL1'}[1] || 0,
			$stats->{'TOTAL1'}[2] || 0, $stats->{'TOTAL1'}[3] || 0);
		printf $printf,
			"nolabel1",
			$total, $proposed, $correct_unlbl, 
			sprintf("%.1f", 100 * $correct_unlbl / max(1, $proposed)), 
			sprintf("%.1f", 100 * $correct_unlbl / max(1, $total)), 
			sprintf("%.1f", 200 * ($correct_unlbl / max(1, $proposed)) 
				* ($correct_unlbl / max(1, $total)) 
				/ max(0.00001, ($correct_unlbl / max(1, $proposed) 
						+ $correct_unlbl / max(1, $total))));

		# Print relative annotation time compared to manual
		print "\n\nRelative annotation time for automatic relative to manual annotation\n    = ((GOLD-CORRECT) + 2*(PROPOSED-CORRECT))/GOLD = "
			. sprintf("%.1f%%\n", 100 * (
				($total - $correct) 
					+ 2 * ($proposed - $correct)) / max(1, $total));

		# Print relative annotation time compared to manual
		print "\nRelative annotation time for automatic with precision > 50% relative to manual annotation\n";
		print "using labels: " . join(" ", sort(keys(%$labels50))) . "\n";
		print "    = ((GOLD-PROPOSED50) + 2*(PROPOSED50-CORRECT50))/GOLD = "
			. sprintf("%.1f%%\n", 100 * (
				($total - $proposed50
					+ 2 * ($proposed50 - $correct50)) / max(1, $total)));
	}

	# Update graph
	$self->cmd_return() if (! $self->abort());

	# Return
	return 1;
}

sub compare_graphs {
	my ($self, $graph, $pos) = @_;

	# Calculate counts: [$gold, $proposed, $correct, $correct_unlabeled]
	my $stats = {'TOTAL' => [0, 0, 0, 0]};
	for (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		if (! $node->comment()) {
			# Process in-edges
			foreach my $edge (@{$node->in()}) {
				my $label = $edge->type();

				# Initialize counters
				$stats->{$label} = [0, 0, 0] 
					if (! exists $stats->{$label});

				# Determine whether edge is a primary dependency edge or not
				my $primary = ! &$pos($graph, $edge);
				
				if ($edge->var("diff")) {
					# Annotation: proposed
					$stats->{'TOTAL'}[1] ++;
					$stats->{'TOTAL1'}[1] ++ if ($primary);
					$stats->{$label}[1] ++;

					# Correct
					if (! $graph->diffminus($edge)) {
						$stats->{'TOTAL'}[2] ++;
						$stats->{'TOTAL1'}[2] ++ if ($primary);
						$stats->{$label}[2] ++;
					}

					# Correct unlabeled
					if (! $graph->diffminus($edge, 1)) {
						$stats->{'TOTAL'}[3] ++;
						$stats->{'TOTAL1'}[3] ++ if ($primary);
					}
				} else {
					# Gold-standard: total
					$stats->{'TOTAL'}[0] ++;
					$stats->{'TOTAL1'}[0] ++ if ($primary);
					$stats->{$label}[0] ++;
				}
			}
		}
	}

	# Return counts
	return $stats;
}

#	# Compare edges in graphs, node by node
#	my $n = max($graph1->size(), $graph2->size());
#	my ($nedges1, $nedges2, $nplus1, $nplus2) = (0, 0, 0, 0);
#	for (my $i = 0; $i < $n; ++$i) {
#		my $node1 = $graph1->node($i) || Node->new();
#		my $node2 = $graph2->node($i) || Node->new();
#		
#		# Find edges which only exist at one node, and print differences
#		my $plus1 = edge_setdiff($node1->in(), $node2->in(), "diff:");
#		my $plus2 = edge_setdiff($node2->in(), $node1->in(), "diff: del");
#
#		# Count edges
#		$nedges1 += scalar(@{$node1->in()});
#		$nedges2 += scalar(@{$node2->in()});
#		$nplus1  += scalar(@$plus1);
#		$nplus2  += scalar(@$plus2);
#
#		# Add edges in $graph1 to $graph2, marking them as "diff=1"
#		foreach my $e1 (@{$node1->in() || []}) {
#			my $clone = $e1->clone();
#			$clone->var('diff', '1');
#			$graph2->edge_add($clone);
#		}
#
#		# Abort if requested
#		last() if ($self->abort());
#	}
#	# Print status
#	printf "statistics: edges1=%i edges2=%i plus1=%i plus2=%i diff=%.4g%%\n",
#		$nedges1, $nedges2, $nplus1, $nplus2, 
#		100 * ($nplus1 + $nplus2) / (($nedges1 + $nedges2) || 1); 
#

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_display.pl
## ------------------------------------------------------------

sub cmd_display {
	my $self = shift;
	my $graph = shift || $self->graph();
	my $followfile = $graph->fpsfile() || $self->fpsfile();
	my $displayfile = shift || $followfile;

	if ( -r $displayfile ) {
		system("cp $displayfile $followfile");
	} else {
		error("Cannot read file: $displayfile\n");
	}
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_echo.pl
## ------------------------------------------------------------

sub cmd_echo {
	my $self = shift;
	my $table = shift;
	my $string = shift;

	# Check whether table exists
	$string =~ s/\\n/\n/g;
	if (! defined($table)) {
		print $string;
	} else {
		my $tablenames = $self->{'tablenames'} || {};
		my $tables = $self->{'tables'} || [];
		my $ofh = $table ? $tablenames->{$table} : 
			($#$tables >= 0 ? $tables->[$#$tables] : undef);
		if (! defined($ofh)) {
			error("The table " . (defined($table) ? $table : "undef") . " does not exist, or has been closed.");
		} else {
			print $ofh $string;
		}
	}

	# Return 
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_edel.pl
## ------------------------------------------------------------

sub cmd_edel {
	my $self = shift;
	my $graph = shift;
	my $noderel = shift;

	# Apply offset
	my $node = defined($noderel) ? $noderel + $graph->offset() : undef;

	# Check that $nodein is valid
	my $n  = $graph->node($node);
	return error("Non-existent node: " . ( $node || "?")) 
		if ((! defined($node)) || (! ref($n)));

	# Delete all in-edges at $n
	my @edges = @{$n->in()};
	foreach my $e (@edges) {
		# Delete edge if it matches description
		$graph->edge_del($e) 
	}

	# Mark graph as modified
    $graph->mtime(1);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_edge.pl
## ------------------------------------------------------------

sub cmd_edge {
	my $self = shift;
	my $graph = shift;
	my $nodein = shift() + $graph->offset();
	my $etype = shift;
	my $nodeout = shift() + $graph->offset();

	# Split type into multiple types
	my $edgesplits = $self->var("edgesplits") || [];
	foreach my $edgesplit (@$edgesplits) {
		#print "edgesplit: $edgesplit etype1=$etype ";
		eval("\$etype =~ $edgesplit");
		#print "etype2=$etype\n";
	}

	# Test whether edge is primary, and delete old incoming primary
	# edges first, if requested
	if (($self->option("autodelete") || "") eq "on" || ($graph->var("autodelete") || "") eq "on") {
		if ($graph->is_dependent($etype)) {
			my $node = $graph->node($nodein);
			my $edges = [];
			push @$edges, @{$node->in()} if ($node);
			foreach my $e (@$edges) {
				if ($graph->is_dependent($e->type())) {
					inform("Autodeleting primary edge: " .  $e->as_string());
					$graph->edge_del($e);
				} 
			}
		}
	}

	# Add edge(s) and mark graph as modified
	foreach my $t (split(/\s+/, $etype)) {
		$graph->edge_add(Edge->new($nodein, $nodeout, $t))
			if ($t !~ /^\s*$/);
	}

	# Update graph as modified
	$graph->mtime(1);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_edges.pl
## ------------------------------------------------------------

sub cmd_edges {
	my ($self, $graph, $noder) = @_;

	# Dependency graphs
	if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
			&& defined($noder) && $noder =~ /^[0-9]+$/)  {
		my $node = $graph->node(($noder || 0) + $graph->offset());
		if (! $node) {
			return error("non-existent node $noder\n");
		} else {
			my @iedges = map {
					($_->in() - $graph->offset()) . " "
					. ($_->type()) . " "
					. ($_->out() - $graph->offset()) . "\n"} 
				@{$node->in()};
			my @oedges = map {
					($_->in() - $graph->offset()) . " "
					. ($_->type()) . " "
					. ($_->out() - $graph->offset()) . "\n"} 
				@{$node->out()};
			print "" . (@iedges ? "in:\n  " . join("  ", sort(@iedges))  : "")
				. (@oedges ? "out:\n  " . join("  ", sort(@oedges)) : "");
		}
	}

	# Alignment graphs
	if (UNIVERSAL::isa($graph, 'DTAG::Alignment') && defined($noder) 
			&& $noder =~ /^([a-z])?([0-9]+)$/)  {
		my ($key, $node) = ($1, $2);
		$key = "a" if (! $key);
		$node += $graph->offset($key);
		my @edges = map {
			my $e = $graph->edge($_); 
			($e ? 
				$e->outkey() . 
				print_anodes([map {$_ - $graph->offset($e->outkey())} @{$e->outArray()}]) 
				. ($e->type() ? " " . ($e->type()) . " " : " ") .
				$e->inkey() .
				print_anodes([map {$_ - $graph->offset($e->inkey())} @{$e->inArray()}])
				. "\n"
			: "?")} 
			@{$graph->node_edges($key, $node) || []};
		print join("", sort(@edges));
	}

	return 1;
}

sub print_anodes {
	my $list = shift;
	$list = [sort(@$list)];
	my $inrange = 0;
	my @newlist = ();
	for (my $i = 0; $i <= $#$list; ++$i) {
		if ($i > 0 && $i < $#$list 
				&& $list->[$i-1] + 1 == $list->[$i]
				&& $list->[$i] + 1 == $list->[$i+1]) {
			if ($newlist[$#newlist] ne "..") {
				push @newlist, "..";
			}
		} else {
			if ($i > 0 && $newlist[$#newlist] ne "..") {
				push @newlist, "+";
			}
			push @newlist, $list->[$i];
		}
	}
	return join("", @newlist);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_edgesplit.pl
## ------------------------------------------------------------

sub cmd_edgesplit {
	my $self = shift;
	my $command = shift;

	# Ensure that edgesplits array is present
	my $edgesplits = $self->var("edgesplits");
	$edgesplits = $self->var("edgesplits", []) 
		if (! $edgesplits);

	# Make command
	if ($command =~ /^\s*-clear\s+$/) {
		$self->var("edgesplits", []);
	} elsif ($command =~ /^\s*(s\/.*\/.*\/.*)\s*/) {
		push @$edgesplits, $1;
	} else {
		error("edgesplit: unknown regular expression $command\n");
	}

	# Return 1
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_edit.pl
## ------------------------------------------------------------

sub cmd_edit {
	my $self = shift;
	my $graph = shift;
	my $noder = shift;
	my $varstr = shift;
	my $vars = $self->varparse($graph, $varstr, 1);

	# Apply offset
	my $node = defined($noder) ? $noder + $graph->offset() : undef;

	# Find node 
	my $N = $graph->node($node);

	# Errors: non-existent node, or comment node
	return error("Non-existent node: $noder") if (! $N);
	return error("Node $noder is a comment node.") if ($N->comment());

	# Set values for all given variable-value pairs
	foreach my $var (keys %$vars) {
		if (defined($vars->{$var})) {
			if ($var eq 'input') {
				$N->input($vars->{$var});
			} else {
				$N->var($var, $vars->{$var});
			}
		}
	}

	# Create variable editing string
	my $edit = "";
	my @keys = keys(%$vars);
	@keys = (keys(%{$graph->vars()}), 'input') if (! @keys);
	foreach my $var (@keys) {
		$edit .= "$var=" . (($var eq 'input' 
				? $N->varstr('_input') : $N->varstr($var)) || "") . " "
			if (! defined($vars->{$var}));
	}
	chomp($edit);

	# Edit and mark graph as modified
	if ($edit) {
		$self->nextcmd("edit $node $edit");
	} 
	$graph->mtime(1);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_efilter.pl
## ------------------------------------------------------------

sub cmd_efilter {
	my $self = shift;
	my $graph = shift;
	my $filter = " " . (shift || "");

	# Check that graph is a graph
	if (! UNIVERSAL::isa($graph, 'DTAG::Graph')) {
		error("this command can only be applied to graphs");
		return 1;
	}

	# Unpack filter
	my $default_remove = 0;
	$default_remove = 1 
		if ($filter =~ /\s+\+/ && $filter !~ /\s+-/);
	my $keep = {};
	my $remove = {};
	foreach my $spec (split(/\s+/, $filter)) {
		if ($spec) {
			print "spec: <$spec>\n";
			my $op = substr($spec, 0, 1);
			my $label = substr($spec, 1);
			if ($op eq "+") {
				$keep->{$label} = 1;
			} elsif ($op eq "-") {
				$remove->{$label} = 1;
			}
		}
	}

	# Save default action
	if (! $keep->{""} && ! $remove->{""}) {
		$keep->{""} = 1 if (! $default_remove);
		$remove->{""} = 1 if ($default_remove);
	}

	# Process all edges in the graph
	$graph->do_edges(\&efilter_edge, $graph, $keep, $remove);
	        
	# Return
	return 1;
}

sub efilter_edge {
	my $e = shift;
	my $graph = shift;
	my $keep = shift;
	my $remove = shift;
	my $label = $e->type();

	# Remove edge if it is on remove list and not on keep list
	if (! $keep->{$label} && ($remove->{$label} || $remove->{""})) {
		$graph->edge_del($e);
	}
}
	



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_errordef.pl
## ------------------------------------------------------------

sub cmd_errordef {
	my ($self, $graph, $type, $error, $sub) = @_;

	# Determine error type: -node or -edge
	$type = (($type || "") eq "-edge") ? "edge" : "node";

	# Ensure error definitions exist in both graph and interpreter
	my $gerrordefs = $graph->errordefs();
	my $ierrordefs = $self->{'errordefs'};

	# Create subroutine object
	my $substr = $type eq "node"
		? "sub { my \$I = shift; my \$G = shift; my \$n = shift; "
			. " my \$egov = \$G->govedge(\$n); "
			. " my \$gov = \$G->node(\$egov ? \$egov->out() : undef); "
			. $sub . " }"
		: "sub { my \$I = shift; my \$G = shift; my \$e = shift; "
			. " my \$etype = \$e->type(); "
			. " my \$eout = \$G->node(\$e->out()); "
			. " my \$ein = \$G->node(\$e->in()); "
			. $sub . " }";
	my $subobj = eval($substr);
	error("Perl errors in $type-errordef \"$error\": $sub\n$@") if ($@);

	# Clear from error definitions if subroutine empty
	if ($sub =~ /^\s*$/ || ! $subobj) {
		print "Deleting $type-error definition \"$error\"\n";
		delete $ierrordefs->{$type}{$error};
		delete $gerrordefs->{$type}{$error};
	} else {
		# Save subroutine object in error list
		my $errorlevel = $self->{'errordefid'}++;
		$ierrordefs->{$type}{$error} = [$errorlevel, $subobj, $sub];
		$gerrordefs->{$type}{$error} = [$errorlevel, $subobj, $sub];
	}

	# Sort subroutines
	$ierrordefs->{'@' . $type} = sort_errordefs($ierrordefs->{$type});
	$gerrordefs->{'@' . $type} = sort_errordefs($gerrordefs->{$type});

	# Return
	return 1;
}

sub sort_errordefs {
	# Sort numerically according to increasing error level, then alphabetically
	my $hash = shift;
	return [sort {
			($hash->{$a}[0] <=> $hash->{$b}[0])
			|| $a cmp $b
		} (keys(%$hash))];
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_errordefs.pl
## ------------------------------------------------------------

sub cmd_errordefs {
	my ($self, $graph, $errorspec) = @_;
	
	my $errordefs = $graph->errordefs();
	foreach my $type ("node", "edge") {
		# Find matching errors
		my @matches = ();
		foreach my $e (@{$errordefs->{'@' . $type}}) {
			push @matches, $e
				if ((! $errorspec) || $e =~ /^$errorspec$/);
		}

		# Print matching errors
		if (@matches) {
			print "Error definitions: $type\n";
			foreach my $e (@matches) {
				print "    $e: " . $errordefs->{$type}{$e}[2] . "\n";
			}
			print "\n";
		}
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_errors.pl
## ------------------------------------------------------------

sub cmd_errors {
	my ($self, $graph, $from, $to) = @_;
	$from = 0 if (! defined($from));
	$to = $graph->size() - 1 if (! defined($to));

	# Print error definitions
	my $errors = {};
	my $edgeerrors = {};
	for (my $i = $from; $i <= $to; ++$i) {
		# Skip comment nodes
		my $node = $graph->node($i);
		next if ($node->comment());

		# Test in-edge errors
		my @edgeerrors = ();
		if ($node) {
			foreach my $e (sort {$a->out() <=> $b->out()} @{$node->in()}) {
				my @errorlist = @{$graph->errors_edge($e)};
				foreach my $error (map {$_->[0]} @errorlist) {
					$edgeerrors->{$error} = 1;
					$errors->{$error} = [] 
						if (! exists $errors->{$error});
					push @{$errors->{$error}}, $e->as_string();
				}
				#push @edgeerrors, "    " . $e->as_string() . ": " 
				#		. join(" ", map {$_->[0]} @errorlist) . "\n"
				#	if (@errorlist);
			}
		}

		# Test node errors
		foreach my $error (map {$_->[0]} @{$graph->errors_node($node)}) {
			$errors->{$error} = [] 
				if (! exists $errors->{$error});
			push @{$errors->{$error}}, $i;
		}
		#if (@nodeerrors || @edgeerrors) {
		#	print "$i: " . join(" ", map {$_->[0]} @nodeerrors) . "\n";
		#	print @edgeerrors;
		#}
	}

	# Print all node errors
	foreach my $error (sort(keys(%$errors))) {
		next if ($edgeerrors->{$error});
		print "  " . $error . ": " . join(", ", sort {$a <=> $b} (@{$errors->{$error}})) . "\n";
	}

	# Print all edge errors
	foreach my $error (sort(keys(%$errors))) {
		next if (! $edgeerrors->{$error});
		print "  " . $error . ": " . join(", ", sort 
			{	my ($ain,$aout) = split(/[^0-9]+/, $a);
				my ($bin,$bout) = split(/[^0-9]+/, $b);
				return $ain <=> $bin || $aout <=> $aout;
			} 
			@{$errors->{$error}}) . "\n";
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_etypes.pl
## ------------------------------------------------------------

sub cmd_etypes {
	my $self = shift;
	my $graph = shift;
	my $category = shift || "";
	my $types = shift || "";
	my $add = shift || "";

	# Copy default etypes to graph etypes, if no etypes for graph
	my $etypes1 = {};
	if ($category) {
		my $list = [];
		if ($add) {
			push @$list, @{$graph->etypes()->{$category}};
		}
		push @$list, split(/\s+/, $types);
		$etypes1->{$category} = $list;
	}
	$graph->etypes($etypes1);
	$self->{'etypes'} = $graph->etypes();

	# Print edges
	if (! $self->quiet()) {
		print "\n";
		my $etypes = $graph->etypes();
		foreach my $key (sort(keys %$etypes)) {
			print "EDGE CLASS $key: ", join(" ",
				sort(@{$etypes->{$key}})), "\n\n";
		}
	}

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_example.pl
## ------------------------------------------------------------

sub cmd_example {
	my $self = shift;
	my $graph = shift;
	my $spec = shift;
	my $nopos = shift;
	$spec = "" if (! defined($spec));


	# Create new graph
	my $offset = -1;
	my $add = 0;
	if ($spec =~ /^-add\s+/) {
		$add = 1;
		$spec =~ s/^-add\s+//g;
		my $node = Node->new();
		$node->input("\n");
		$graph->node_add($graph->size(), $node);
		$graph->offset($graph->size());
	} else {
		$self->do("new");
		$graph = $self->graph();
	}
	if ($spec =~ s/^-nopos\s+//) {
		$nopos = 1;
	}

	# Create graph from specification
	my $quiet = $self->quiet();
	$self->quiet(1);
	my $nodes = 0;
	my $edges = [];
	my $inaligns = [];
	my $features = 0;
	my $title = "";
	while (length($spec) > 0) {
		if ($spec =~ s/^-title="(.*)"\s*//) {
			# Title
			$title = $1;
		} elsif ($spec =~ s/^@([^()]*)\(([^,]+),([^,()]+)\)\s*//) {
			my $oset = $2;
			my $iset = $3;
			push @$inaligns, "inalign "
				. map_align_offset($2, -1)
				. " $1 " 
				. map_align_offset($3, -1);
		} elsif ($spec =~ s/^(\S+)\s*//) {
			# Parse node specification
			my $nespec = $1;
			$nespec =~ /^([^<>]+)(<(.*)>)?$/;
			my $nodespec = $1;
			my $edgespec = defined($3) ? $3 : "";
			my $labels = [split(/\|/, $nodespec)];

			# Create node
			my $cmd = "node " . $labels->[0];
			for (my $i = 1; $i <= $#$labels; ++$i) {
				if ($i > $features) {
					$self->do("vars f$i");
					++$features;
				}
				$cmd .= " f$i=\"" . $labels->[$i] . "\"";
			}
			$self->do($cmd);
			++$nodes;

			# Parse edge specification
			foreach my $edge (split(/,/, $edgespec)) {
				$edge =~ /^([0-9]+):(.*)$/;
				my $e = "edge " . ($nodes - 1) . " $2 "
					. ($1 - 1);
				push @$edges, $e;
			}
		} else {
			# Ignore garbage tokens
			$spec =~ s/(\S*)//;
			warning("Couldn't parse $1");
			$spec =~ s/^\s+//;
		}
	}

	# Create edges
	foreach my $edge (@$edges) {
		$self->do($edge);
	}

	# Create inaligns
	foreach my $inalign (@$inaligns) {
		$self->do($inalign);
	}

	# Set layout of nodes
	my @features = sort(keys(%{$graph->vars()}));
	push @features, "_position" if (! $nopos);
	my $cmd = "layout -graph -vars /stream:.*/|" 
		. join("|", @features);
	$self->do("inline 0 #$title") if ($title ne "");
	$self->do($cmd);
	if ($title ne "") {
		if ($add) {	
			$self->do("node x");
			my $titlenode = $graph->node($graph->size()-1);
			$titlenode->input('    "' . $title . '"');
		} else {
			$graph->var("title", $title);
		}
	}

	# Update display
	$self->cmd_return();
	$self->quiet($quiet);
	$graph->offset(0);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_exit.pl
## ------------------------------------------------------------

my $exit_unsaved = 0;

sub cmd_exit {
	my $self = shift;
	my $graph = shift;
	my $really_quit = shift;

	# Only exit from the outer loop
	if ($self->{'loop_count'} > 1) {
		return 1;
	}

	# Save file if modified
	print "\n";
	if ($graph && $graph->mtime() && $exit_unsaved + 60 < time() 
			&& ($really_quit || "") ne "!") {
		warning("You have unsaved graphs!\nType 'exit' or 'exit!' if you really want to quit...");
		$exit_unsaved = time();
		return 1;
	} 

	# Close lexicon
	my $lex = $self->lexicon();
	$lex->close() if ($lex);

	# Close viewers
	local $SIG{INT} = 'IGNORE';
	kill('INT', -$$);

	# Delete follow files
	unlink($graph->fpsfile()) if ($graph && $graph->fpsfile());
	unlink($self->fpsfile()) if ($self && $self->fpsfile());

	# Close cmdlog
	my $cmdlog = $self->var("cmdlog");
	if (defined($cmdlog)) {
	 	print $cmdlog "\n# close cmdlog: " 
			. (`date +'%Y.%m.%d-%H.%M'` || "???") . "\n";
		close($cmdlog);
		$self->var("cmdlog", undef);
	}

	# Kill viewers
	my $cmd = "ps e -w | grep dtag-$$- | grep -v grep | sed -e 's/^ //g' |cut -f1 -d\' \' | xargs -r kill";
	#print "Closing viewers with: $cmd\n";
	system($cmd);

	# Exit
	exit();
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_find.pl
## ------------------------------------------------------------

my $key_names = "123456789abcdefghijklmnopqrstuvwxyz";
my $broken_ReadKey = 1;

sub cmd_find {
	my $self = shift;
	my $graph = shift;
	my $cmd = shift;

	# Process options
	my $time = - time();
	my $match = 0;

	# Parse query string
	$cmd =~ s/^\s*//;
	my $cmd2 = "$cmd";
	my $parse = $self->query_parser()->FindExpression(\$cmd2);
	print "dump: " . dumper($parse) . "\n"
		if (! (defined($parse) && defined($parse->{'options'}) 
			&& ! $parse->{'options'}{'dump'}));

	if ($cmd2) {
		# String was not parsed completely
		error("Illegal search query: error in \"$cmd2\"");
		return 1;
	}

	# Retrieve options, query, and actions
	my $options = $parse->{'options'};
	my $query = $parse->{'query'};
	my $actions = $parse->{'actions'};
	print "Actions: \n";
	foreach my $action (@$actions) {
		print "\t" . $action->print() . "\n";
	}
	print "\n";

	my $timeout = $options->{'maxtime'} || "0";
	my $matchout = $options->{'maxmatch'} || "0";
	my $debug = $options->{'debug'};
	my $debug_parse = $options->{'debug_parse'};
	my $debug_dnf = $options->{'debug_dnf'};
	my $corpus = $options->{'corpus'};
	my $safe = $options->{'safe'};
	my $varkeys = $options->{'vars'} || {};

	# Print debugging output of parse
	if ($debug_parse || $debug_dnf || $debug) {
		$self->print("find", "result", 
			"input=$cmd\n"
			. (defined($timeout) ? "maxtime=$timeout\n" : "")
			. (defined($matchout) ? "maxmatch=$matchout\n" : "")
			. ((ref($query) && UNIVERSAL::isa($query, 'HASH'))
				? "vars=" . join(" ", sort(keys(%{$query->unbound({})})))
					. "\n" 
				: "")
			. "varkeys=" . join(" ", map {$_ . ($varkeys->{$_} ? "@" . $varkeys->{$_} : "")}
					sort(keys(%$varkeys))) . "\n"
			. ("query=" 
				. ((ref($query) && UNIVERSAL::can($query, "print")) 
					? $query->print() : dumper($query)) . "\n"));
		return 1 if ($debug_parse);
	}

	# Check that all variables have a valid key unless the graph is a Graph.
	if (! UNIVERSAL::isa($graph, "DTAG::Graph")) {
		foreach my $var (keys(%{$query->unbound({})})) {
			if (! $graph->graph($varkeys->{$var})) {
				error("When searching an alignment, you must use the -vars option\n" 
					. "to specify keys for all variables in the query.");
				return 1;
			}
		}
	}
	my $abort = 0;
	foreach my $var (keys(%$varkeys)) {
		my $key = $varkeys->{$var};
		my $keygraph = $graph->graph($key);
		if (! defined($keygraph)) {
			error("Undefined graph key \"" . (defined($key) ? $key : "") 
				. "\" for variable $var!");
			$abort = 1;
		}
	}
	return 1 if ($abort);

	# Reduce query string to disjunctive normal form
	my $dnf = ref($query) ? $query->dnf() : undef;
	my $oquery = $query->pprint();
	my $rquery = $dnf->pprint();
	$self->print("find", "result",
		"Executing query\n\n\t$oquery\n\n" .
			($oquery ne $rquery ? "as query\n\n\t$rquery\n\n"
				: ""));
	return 1 if ($debug_dnf);

	# Reset found matches and disable follow
	my $matches = $self->{'matches'} = {};
	my $maxsols = 100000;				# Maximal number of full solutions
	my $noview = $self->var("noview");
	$self->var("noview", 1);

	# Solve DNF-query for all files in corpus
	my $iostatus = $|; $| = 1; my $c = 0;
	my $progress = "";
	my $findfiles = $corpus ? $self->{'corpus'} : [$self->graph()->id()];
	my $count = 0;
	my $display = 1;
	my $ask = $self->interactive() && ! $options->{'replace-all'};
	my $laststatus = time() - 1;
	foreach my $f (@$findfiles) {
		# Load new file from corpus, if this is a corpus search 
		$self->cmd_load($graph, undef, $f) 
			if ($corpus);
		$graph = $self->graph();

		# Print progress report 
		if ($corpus && ! $self->quiet()) {
	 		if (time() > $laststatus + 0.5 ) {
				$laststatus = time();
				my $blank = "\b" x length($progress);
				my $percent = int(100 * $c / (1 + $#$findfiles));
				$progress = 
					sprintf('Searched %02i%%. Elapsed: %s. ETA: %s. Matches: %i.',
					$percent,
					seconds2hhmmss(time()+$time),
					seconds2hhmmss(int((100-$percent) 
							/ ($percent || 1) * (time()+$time))),
					$count);
				$self->print("find", "status", $blank . $progress);
			}
			++$c;
		}

		# Solve DNF-query for all conjunctions in disjunction
		foreach my $and (@{$dnf->{'args'}}) {
			# Push all solutions onto list of matches
			my $solutions = 
				$and->solve($graph, $maxsols, 
					{'vars' => $varkeys});
			if (@$solutions) {
				$matches->{$f} = [] if (! $matches->{$f});

				# Process solutions
				foreach my $s (@$solutions) {
					push @{$matches->{$f}}, $s;
					$count += 1;
				}
			}

			# Abort if timeout and matchout have been exceeded
			$self->abort(1) if (($matchout && $count > $matchout) 
				|| ($timeout && (time()+$time) > $timeout));

			# Catch abort request
			last() if $self->abort();
		}

		# Replace all matches in $matches->{$f}
		foreach my $action (@$actions) {
			my $choice = "N";
			foreach my $binding (@{$matches->{$f}}) {
				# Select replace operation
				$choice = "Y";
				if ($ask && $action->ask()) {
					# Update graph
					++$match;
					$self->cmd_goto($graph, "M$match");

					# Print replace operations
					print "Replace operations for ",
						$self->print_match($match, $f, $binding), "\n",
						"    ", $action->string(), "\n",
						"    [Y]es [N]o [A]ll [Q]uit [E]dit\n";

					# Read choice
					$choice = " ";
					while (ReadKey(-1)) { };		# ignore any input
					while ("YNAQE" !~ /$choice/) {
						$choice = ($broken_ReadKey ? getc() : ReadKey(-1)) 
							|| "_";
						print "[$choice]";
						sleep(1);
					}
					#ReadMode('normal') if (! $broken_ReadKey); 
				}

				# Process choice: AYN0
				if ($choice eq "N" || $choice eq "0") { next() };
				if ($choice eq "Q") { last() };
				if ($choice eq "A") { $ask = 0; print "\n"; };

				# Manual edit or automatic replacement
				if ($choice eq "E") {
					# Manual edit
					$self->var("noview", 0);
					$self->loop();
					$self->var("noview", 1);
					next();
				} elsif ($choice eq "A" || $choice eq "Y") {
					$binding->{'$FILE'} = $graph->file();
					$binding->{'$GRAPH'} = $f;
					$action->do($graph, $binding, $self, $ask);
				}

				# Show result and wait for keypress
				last() if ($self->abort());
			}

			# Save file if corpus replace
			$self->cmd_save_tag($graph)
				if ($corpus && $graph->mtime());

			# Quit if requested by Q or abort
			last() if ($choice eq "Q" || $self->abort());
		}

		# Abort on request
		last() if ($self->abort());
	}
	print "\b" x length($progress)
		. " " x length($progress) 
		. "\b" x length($progress)
			if ($corpus && ! $self->quiet());
	$| = $iostatus;

	# Close actions
	foreach my $action (@$actions) {
		$action->close();
	}

    # Print search statistics
	$time += time();
	print "$count matches found in " . seconds2hhmmss($time) 
		. " for query \"$cmd\".\n" if (! $self->quiet());


	# Restore viewing
	$self->var("noview", 0);

	# Show first match
	$self->cmd_goto($graph, 'M1') if ($count);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_fixations.pl
## ------------------------------------------------------------

sub cmd_fixations {
	my $self = shift;
	my $graph = shift;
	my $fixid = shift;
	my $attrd = shift || "dur";
	my $attrg = shift || "cur";
	my $attrf = shift || $attrg;

	# Retrieve fixation graph
	my $fixgraph;
	if ($fixid =~ /^F\[[0-9]+\]$/) {
		# File already loaded with id $fixid
		my $fixindex = $self->gid2index($fixid);
		$fixgraph = $self->{'graphs'}->[$fixindex]
			if (defined($fixindex));
	} else {
		# Load fixations from file
		my $curgraph = 
		$fixgraph = DTAG::Graph->new($self);
        $fixgraph->file($fixid);
		$self->cmd_load_fix($fixgraph, $fixid, 1);
	}
	if (! defined($fixgraph)) {
		error("Could not find fixation graph $fixid\n");
		return 1;
	}

	# Assign fixation graph to graph
	$graph->var("fixations", []) 
		if (! defined($graph->var("fixations")));
	my $fixations = $graph->var("fixations");
	push @$fixations, [$fixgraph, $attrd, $attrg, $attrf, 0, 0, $fixgraph->size() - 1, $fixid];
	print "Added fixations $fixid to graph " . $graph->id() 
			. " (linking attribute: graph=$attrg fixations=$attrf)\n"
		if (! $self->quiet());

	# Return
	return 1;
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_follow.pl
## ------------------------------------------------------------

sub cmd_follow {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Update follow file and print
	$graph->fpsfile($file);
	$self->cmd_return($graph);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_format.pl
## ------------------------------------------------------------

sub cmd_format {
	my $self = shift;
	my $graph = shift;
	my $var = shift;
	my $regexp = shift;

	# Call corresponding layout command
	$self->cmd_layout($graph, "-var $var $regexp");

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_gedit.pl
## ------------------------------------------------------------

sub cmd_gedit {
	my $self = shift;
	my $graph = shift;
	my $lineno = shift || 0;

	my $file = $graph->file();
	$graph->var("gedit", 1);
	system("gedit +" . (++$lineno) . " $file &");
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_goto.pl
## ------------------------------------------------------------

sub cmd_goto {
	my $self = shift;
	my $graph = shift;
	my $cmd = shift || 0;
	my $mod = shift;

	if ($cmd =~ s/^-context\s+([0-9]+)\s*//) {
		# Set goto context size
		$self->var('goto_context', $1 || 0);
	} elsif ($cmd =~ /^\s*[GA]([0-9]+)\s*$/) {
		# Goto graph specified by graph index
		$self->goto_graph($1 - 1);
	} elsif ($cmd =~ /^\s*([GA]\[[0-9]+\])\s*$/) {
		# Goto graph specified by graph id
		$self->cmd_load($graph, undef, $1);
	} elsif ($cmd =~ /^\s*G([0-9]+):([0-9]+)\s*$/) {
		# Goto graph specified by graph id and node id
		$self->goto_graph($1 - 1);
		$self->cmd_show($self->graph(), $2);
	} elsif ($cmd =~ /^\s*(next\s*[gG]||[gG]\+)\s*$/) {
		# Goto next graph
		$self->goto_graph($self->{'graph'} + 1);
	} elsif ($cmd =~ /^\s*(prev\s*[gG]|[gG]-)\s*$/) {
		# Goto previous graph
		$self->goto_graph($self->{'graph'} - 1);
	} elsif ($cmd =~ /^\s*M([0-9]+)\s*$/) {
		# Goto match specified by match id
		$self->goto_match($1);
	} elsif ($cmd =~ /^\s*(next\s*[mM]?|[mM]\+)\s*$/) {
		# Goto next match
		$self->goto_match(($self->{'match'} || 0) + 1);
	} elsif ($cmd =~ /^\s*(prev\s*[mM]?|[mM]-)\s*$/) {
		# Goto previous match
		$self->goto_match(($self->{'match'} || 0) - 1);
	} else {
		# Unknown goto command
		print "goto: unknown command $cmd\n";
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_graphs.pl
## ------------------------------------------------------------

sub cmd_graphs {
	my $self = shift;
	my $graph = shift;

	# Print graphs
	my $i = 1;
	my $current = $self->{'graph'} || 0;
	foreach my $g (@{$self->{'graphs'}}) {
		print $g->print_graph($current, $i);
		++$i;

		# Abort if requested
		last() if ($self->abort());
	}

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_help.pl
## ------------------------------------------------------------

sub cmd_help {
	my $self = shift;
	my $cmd = shift;

	if ($cmd) {
		if (defined($commands->{$cmd})) {
			print print_cmd($cmd);
		} else {
			error("Unknown command $cmd");
		}
	} else {
		foreach my $key (sort(keys %$commands)) {
			print print_cmd($key);
		}
	}

	return 1;
}

sub print_cmd {
	my $cmd = shift;
	return colored("$cmd: " . ($commands->{$cmd}[1] || ""), "bold") . "\n    " 
		. ($commands->{$cmd}[0] || "") . "\n";
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_inalign.pl
## ------------------------------------------------------------

sub cmd_inalign {
	my $self = shift;
	my $graph = shift;
	my $from = map_align_offset(shift, $graph->offset());
	my $to = map_align_offset(shift, $graph->offset());
	my $label = shift;
	$label = "" if (! defined($label));

	# Store alignment edge in graph (in toggle fashion, so it is
	# deleted if it already exists)
	if (exists $graph->{'inalign'}{"$from $to $label"}) {
		delete $graph->{'inalign'}{"$from $to $label"};
	} else {
		$graph->{'inalign'}{"$from $to $label"} = 1;
	}

	# Return
	return 1;
}

sub map_align_offset {
	my $spec = shift;
	my $offset = shift;
	my $result = "";
	while (length($spec) > 0) {
		if ($spec =~ s/^(-?[0-9]+)//) {
			$result .= ($1 + $offset);
		} else {
			$spec =~ s/^([^0-9-]+)//g;
			$result .= $1;
		}
	}
	return $result;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_inline.pl
## ------------------------------------------------------------

sub cmd_inline {
	my $self = shift;
	my $graph = shift;
	my $posr = shift;
	my $inline = shift;

	$self->cmd_comment($graph, $posr, "<!-- <dtag>$inline</dtag> -->");
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_kgoto.pl
## ------------------------------------------------------------

my $kgoto_server = 0;

sub cmd_kgoto {
	my $self = shift;
	my $graph = shift;
	my $time = shift || 0;

	# Create server
	my $server = $graph->var("gvim");
	if (! $server) {
		print "Start new gvim\n";
		$server = $graph->var("gvim", "DTAG-keyview." . ++$kgoto_server);
		system("gvim --servername $server -geometry 80x24-0+0");
		system("gvim --servername $server --remote-send ':set ww=hl\n'");
	}

	# Create vim command
	my $vim = "1GdGi";
	for (my $i = 0; $i < $graph->size(); ++$i) {
		# Check time
		my $node = $graph->node($i);
		my $ntime = $node->var("time");
		print "ntime=$ntime time=$time\n";
		last if (defined($ntime) && $ntime > $time);
		my $nvim = $node->var("vim");
		$vim .= $nvim if (defined($nvim));
	}

	# Send vim command to server
	system("gvim --servername $server --remote-send '$vim'");
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_kplay.pl
## ------------------------------------------------------------

sub cmd_kplay {
	my $self = shift;
	my $graph = shift;
	my $speed = shift || 1;
	my $time0 = shift || 0;
	my $time1 = shift || 25;

	# Calculate step size in seconds 
	my $updatesPerSec = 5;
	my $step = $speed / $updatesPerSec;

	my $systime0 = time();
	for (my $t = $time0; $t < $time1; $t += $step) {
		$self->cmd_kgoto($graph, $t);
		sleep(1.0 / $updatesPerSec);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_layout.pl
## ------------------------------------------------------------

sub cmd_layout {
	my $self = shift;
	my $graph = shift;
	my $opt = shift;

	# Remove -edge or -node specification
	my $lparent = $self;
	$lparent = $graph if ($graph && $opt =~ s/^-graph\s*//);
	$lparent->{'layout'} = {} if ($opt =~ s/^-clear\s*//);

	# Perform layout action
	if ($opt =~ /^-vars\s+(\S+)\s*$/) {
		# vars: -vars $list
		$lparent->{'layout'}{'vars'} = $1;
	} elsif ($opt =~ /^-var\s+(\S+)\s+sub\s+(.*)$/) {
		# var: -var $var sub $code
		$lparent->{'layout'}{'var'}{$1} = eval("sub $2");
	} elsif ($opt =~ /^-var\s+(\S+)\s+(.*)$/) {
		# var: -var $var $regexp
		$lparent->{'layout'}{'var'}{$1} 
			= eval("sub {my \$v = shift(); \$v = \"\" if (!  defined(\$v)); \$v =~ $2; \$v}");
	} elsif ($opt =~ /^-stream\s+(.*)$/) {
		# stream: -stream $code
		$lparent->{'layout'}{'stream'} 
			= eval("sub { my \$G = shift; my \$n = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-nstyles\s+(.*)$/) {
		# node styles: -nstyles $code
		$lparent->{'layout'}{'nstyles'} 
			= eval("sub { my \$G = shift; my \$n = shift; my \$l= shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-pos\s+(.*)$/) {
		# edge position: -pos $code
		$lparent->{'layout'}{'pos'} 
			= eval("sub { my \$G = shift; my \$e = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-estyles\s+(.*)$/) {
		# edge styles: -estyles $code
		$lparent->{'layout'}{'estyles'} 
			= eval("sub { my \$G = shift; my \$e = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-nhide\s+(.*)$/) {
		# hide: -nhide $code
		$lparent->{'layout'}{'nhide'}
			= eval("sub { my \$G = shift; my \$n = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-ehide\s+(.*)$/) {
		$lparent->{'layout'}{'ehide'}
			= eval("sub { my \$G = shift; my \$e = shift; $1 }");
		error("errors in Perl code: $1\n$@") if ($@);
	} elsif ($opt =~ /^-pssetup\s+"(.*)"\s*$/) {
		$lparent->{'layout'}{'pssetup'} = $1;
	} else {
		return 0;
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_lexicon.pl
## ------------------------------------------------------------

sub cmd_lexicon {
	my $self = shift;
	my $lexname = shift;

	# Close old lexicon
	my $old = $self->lexicon();
	$lexname = $old->name() 
		if ((! $lexname) && UNIVERSAL::isa($old, 'DTAG::Lexicon'));
	$old->close() if ($old);

	# Change lexicon
	print "Current lexicon is: $lexname\n" if (! $self->quiet());
	my $new = DTAG::Lexicon->new($lexname);
	if ($new) {
		$new->name($lexname);
		$self->lexicon($new);
		DTAG::LexInput->lexicon($new);
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_list.pl
## ------------------------------------------------------------

sub cmd_list {
	my $self = shift;
	my $cmd = shift || "";

	# Print matches
	if ($cmd =~ s/\s*-match(es)?\s*//) {
		# Print all matches
		my $matches = $self->{'matches'};
		my $i = 0;
		foreach my $f (sort(keys(%$matches))) {
			foreach my $m (@{$matches->{$f}}) {
				++$i;
				print $self->cmd_list_matchno($i, $f, $m) . "\n";
			}
		}
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_list_matchno.pl
## ------------------------------------------------------------

sub cmd_list_matchno {
	my $self = shift;
	my $match = shift;
	my $file = shift;
	my $binding = shift;

	my @vars = sort(keys(%$binding));
	return "match $match = $file: "
		. "(" . join(", ", @vars) . ")"
		. " = (" . join(", ", map {$binding->{$_}} (@vars)) . ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load.pl
## ------------------------------------------------------------

sub cmd_load {
	my $self = shift;
	my $graph = shift;
	my $ftype = shift;
	my $fname = shift || "";
	my $optionstr = shift || "";
	$fname =~ s/~/$ENV{HOME}/g;

	# Process options: permitted options {multi=0/1 (create new graph,
	# add to current graph)}
	my $multi = 0;
	$multi = 1 if ($optionstr =~ /-multi/);

    # Open internal graph if $file is an internal graph reference
    if ($fname =~ /^[GA]\[([0-9]+)\]$/) {
        my @graphs = @{$self->{'graphs'}};
        for (my $g = 0; $g < scalar(@graphs); ++$g) {
            if ($graphs[$g]->id() eq $fname) {
				$self->goto_graph($g);
                return 1;
            }
        }
    }

 	# Guess file type
	if (! $ftype) {
		# Default file type
		$ftype = '-tag';

		# Guess file type from extension
		$ftype = '-atag' if ($fname =~ /\.atag$/);
		$ftype = '-key' if ($fname =~ /\.key$/);
		$ftype = '-fix' if ($fname =~ /\.fix$/);
		$ftype = '-eye' if ($fname =~ /\.eye$/);
		$ftype = '-lex' if ($fname =~ /\.lex$/);
		$ftype = '-match' if ($fname =~ /\.match$/);
		$ftype = '-tiger' if ($fname =~ /\.xml$/);
		$ftype = '-malt' if ($fname =~ /\.malt$/);
		$ftype = '-conll' if ($fname =~ /\.conll$/);
	}

	# Load file
	$self->cmd_load_tag($graph, $fname, $multi) if ($ftype eq '-tag');
	$self->cmd_load_atag($graph, $fname) if ($ftype eq '-atag');
	$self->cmd_load_key($graph, $fname, $multi) if ($ftype eq '-key');
	$self->cmd_load_eye($graph, $fname, $multi) if ($ftype eq '-eye');
	$self->cmd_load_fix($graph, $fname, $multi) if ($ftype eq '-fix');
	$self->cmd_load_tiger($graph, $fname) if ($ftype eq '-tiger');
	$self->cmd_load_malt($graph, $fname) if ($ftype eq '-malt');
	$self->cmd_load_emalt($graph, $fname) if ($ftype eq '-emalt');
	$self->cmd_load_conll($graph, $fname) if ($ftype eq '-conll');
	$self->cmd_load_lex($graph, $fname) if ($ftype eq '-lex');
	$self->cmd_load_matches($fname) if ($ftype eq '-match');

	# Return with success
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_atag.pl
## ------------------------------------------------------------

sub cmd_load_atag {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Disable viewer and close current graph, if unmodified
	my $noview = $self->var("noview");
	$self->var("noview", 1);
	my $viewer = $self->{'viewer'};
	$self->cmd_load_closegraph($graph) if ($graph);

	# Create new graph 
	my $alignment = DTAG::Alignment->new($self);
	$alignment->file($file);
	my $lastgraph = $graph;

	# Read ATAG file line by line
	open("ATAG", "< $file") 
		|| return error("cannot open atag-file for reading: $file");
	$self->{'viewer'} = 0;
	my $lineno = 0;
	my @graphs = ($alignment);
    while (my $line = <ATAG>) {
        chomp($line);

		# Process file
		if ($line =~ 
				/^<alignFile key="([a-z])" href="([^"]*)".*\/>$/) {
			# <alignFile> tag
			my $key = $1;
			my $afile = $2;

			# Translate relative path name into absolute
			my $basedir = dirname($file);
			if ($afile =~ /^\./) {
				$afile = "$basedir/$afile";
			}

			# Load aligned file and fail if loading failed
			$self->cmd_load($lastgraph, "", $afile);
			$graph = $self->graph();
			if ($graph == $lastgraph) {
				error("failed to load file $afile in alignment file $file");
				$self->{'viewer'} = $viewer;
				close("ATAG");
				return 1;
			}

			# Add graph to alignment
			$alignment->add_graph($key, $graph);
			$graph->var("imin", 0);
			$graph->var("imax", $graph->size());
			push @graphs, $graph;

			# Specify follow psfile
			$graph->fpsfile($self->fpsfile($key))
				if ($self->fpsfile($key));
		} elsif ( $line =~
				/^<align out="([^"]+)" type="([^"]*)" in="([^"]+)" creator="([0-9-]+)".*\/>$/ 
			|| $line =~
				/^<align out="([^"]+)" type="([^"]*)" in="([^"]+)".*\/>$/ ) {
			# Create alignment edge
			my $out = $1;
			my $type = $2;
			my $in = $3;
			my $creator = $4;

			# Replace spaces with "+"
			$out =~ s/ /+/g;
			$in =~ s/ /+/g;

			# Create edge
			$self->cmd_align($alignment, $out, $type, $in, $creator, 0, $lineno);
		} elsif ($line =~ /^<compound node=\"([^"]+)">(.*)<\/compound>$/) {
			$alignment->{'compounds'}{$1} = $2;
		} elsif ($line =~ /<\/?DTAGalign>/) {
			# Do nothing
		} else {
			print "ignored: $line\n" if (! $self->quiet());
		}
		$lineno++;
	}

	# Close ATAG file
	close("ATAG");

	# Push alignment on top of graph stack
	$self->{'viewer'} = $viewer;
	push @{$self->{'graphs'}}, $alignment;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# View alignments
	$self->var("noview", $noview);
	foreach my $g (@graphs) {
		$self->cmd_return($g);
	}
	return $alignment;
}




## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_closegraph.pl
## ------------------------------------------------------------

sub cmd_load_closegraph {
	my $self = shift;
	my $graph = shift;

	# Close current graph, if unmodified
	if (! $graph->mtime()) {
		$self->{'graphs'} = [grep {$_ != $graph} @{$self->{'graphs'}}];
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_conll.pl
## ------------------------------------------------------------

sub cmd_load_conll {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Open tag file
	open("CONLL", "< $file") 
		|| return error("cannot open CONLL-file for reading: $file");
	
	# Close current graph, if unmodified
	$self->cmd_load_closegraph($graph);

	# Create new graph
	$graph = DTAG::Graph->new($self);
	$graph->file($file);
	push @{$self->{'graphs'}}, $graph;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	$graph->vars()->{'msd'} = undef;

	# Read CONLL file line by line
	my $offset = 0;
	my $edges = [];
	my $pos = 0;
    while (my $line = <CONLL>) {
		# Process CONLL line
        chomp($line);
		my ($ID, $FORM, $LEMMA, $CPOSTAG, $POSTAG, $FEATS,
			$HEAD, $DEPREL, $PHEAD, $PDEPREL) = split(/	/, $line);

		# Create node and add it to graph
		my $n = Node->new();
		my $in = $graph->size();
		if ($line) {
			# Setup node
			$n->input($FORM);
			$n->var('lemma', $LEMMA) if ($LEMMA && $LEMMA ne "_");
			$n->var('cpos', $CPOSTAG) if ($CPOSTAG && $CPOSTAG ne "_");
			$n->var('pos', $POSTAG) if ($POSTAG && $POSTAG ne "_");
			$n->var('feats', $FEATS) if ($FEATS && $FEATS ne "_");
			$n->var('phead', $PHEAD) if ($PHEAD && $PHEAD ne "_");
			$n->var('pdeprel', $PDEPREL) if ($PDEPREL && $PDEPREL ne "_");
			$graph->node_add($in, $n);

			# Create edge
			my $e = Edge->new();
			$e->in($in);
			$e->type($DEPREL || "");
			$e->out($HEAD - $ID + $in);
			push @$edges, $e if ($HEAD);
		} else {
			$n->comment(1);
			$n->input('</s>');
			$offset = $graph->size();
			$graph->node_add($in, $n);
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Add edges
	foreach my $e (@$edges) {
		$graph->edge_add($e) 
			if ($e->out() >= 0);
	}

	# Close CONLL file
	close("CONLL");
	$self->cmd_return($graph);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_emalt.pl
## ------------------------------------------------------------

sub cmd_load_emalt {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Open tag file
	open("MALT", "< $file") 
		|| return error("cannot open MALT-file for reading: $file");
	
	# Read graph
	my $malt2node = {};
	my $line = 0;
	my $sent = 0;
	for (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		my $input = $node->input();
		if (! $node->comment()) {
			++$line;
			$malt2node->{"$sent:$line"} = $i;
		} elsif ($input =~ /<\/s>/) {
			++$sent;
			$line = 0;
		}
	}

	# Read MALT file line by line
	my $pos = 0;
	$sent = 0;
    while (my $line = <MALT>) {
		# Ignore blank lines
        chomp($line);
		if (! $line) {
			++$sent;
			$pos = 0;
			next();
		}
		
		# Process MALT line
		++$pos;
		my ($input, $msd, $head, $type) = split(/	/, $line);

		# Check that nodes match
		my $in = $malt2node->{"$sent:$pos"};
		my $nodein = $graph->node($in);
        my $input2 = ($nodein ?  $nodein->input() : "") || "";
		if (($input2 || "") ne ($input || "")) {
			warning("non-matching input $sent:$pos: tag-node=$in ["
			. ($input2 || "undef") . "] malt-node=$pos ["
			. ($input || "undef") . "]");
		} else {
			# Create edge
			if ($head) {
				my $e = Edge->new();
				$e->in($in);
				$e->type($type);
				$e->out($malt2node->{"$sent:$head"});
				$graph->edge_add($e);
			}
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Close MALT file
	close("MALT");
	$self->cmd_return($graph);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_eye.pl
## ------------------------------------------------------------

sub cmd_load_eye {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $multi = shift;

	# Open tag file
	open("XML", "< $file") 
		|| return error("cannot open eye-file for reading: $file");
	CORE::binmode("XML", $self->binmode()) if ($self->binmode());
	
	# Close current graph, if unmodified
	if (! $multi) {
		# Close old graph and create new graph
		$self->cmd_load_closegraph($graph);
		$graph = DTAG::Graph->new($self);
		$graph->file($file);
		push @{$self->{'graphs'}}, $graph;
		$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	}
	my @edges = ();

	# Read XML file line by line
	my $varnames = {};
	my $lineno = 0;
    while (my $line = <XML>) {
        chomp($line);
		my $n = Node->new();
		my $pos = $graph->size();

		# Record line number and source
		if ($multi) {
			++$lineno;
			$n->var('_source', "$file:$lineno");
		}

		# Process <W> tag
		if ($line =~ /^\s*<E(.*)\/>\s*/) {
			my $varstr = $1;
			my $vars = $self->varparse($graph, $varstr, 0);
			my $input = "";
			$n->input($input);
			$n->type("E");
			$graph->node_add($pos, $n);
			foreach my $var (keys(%$vars)) {
				$varnames->{$var} = 1;
				$n->var($var, $graph->xml_unquote($vars->{$var}));
			}
		} else {
			# Comment line: insert as verbatim node
			$n->input($line);
			$n->comment(1);
			$graph->node_add($pos, $n);

			# Process comment, if it represents inline dtag command
			if ($line =~ /^\s*<!--\s*<dtag>(.*)<\/dtag>\s*-->\s*$/) {
				$self->do($1) if ($self->unsafe());
			}
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Insert varnames as permitted varnames
	foreach my $var (keys(%$varnames)) {
		$graph->vars()->{$var} = undef 
			if (! exists $graph->vars()->{$var});
	}

	# Close XML file
	close("XML");
	$self->cmd_return($graph);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_fix.pl
## ------------------------------------------------------------

sub cmd_load_fix {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $multi = shift;

	# Open tag file
	open("XML", "< $file") 
		|| return error("cannot open fix-file for reading: $file");
	CORE::binmode("XML", $self->binmode()) if ($self->binmode());
	
	# Close current graph, if unmodified
	if (! $multi) {
		# Close old graph and create new graph
		$self->cmd_load_closegraph($graph);
		$graph = DTAG::Graph->new($self);
		$graph->file($file);
		push @{$self->{'graphs'}}, $graph;
		$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	}
	my @edges = ();

	# Read XML file line by line
	my $varnames = {};
	my $lineno = 0;
    while (my $line = <XML>) {
        chomp($line);
		my $n = Node->new();
		my $pos = $graph->size();

		# Record line number and source
		if ($multi) {
			++$lineno;
			$n->var('_source', "$file:$lineno");
		}

		# Process <W> tag
		if ($line =~ /^\s*<F(.*)\/>\s*/) {
			my $varstr = $1;
			my $vars = $self->varparse($graph, $varstr, 0);
			my $input = "";
			$n->input($input);
			$n->type("F");
			$graph->node_add($pos, $n);
			foreach my $var (keys(%$vars)) {
				$varnames->{$var} = 1;
				$n->var($var, $graph->xml_unquote($vars->{$var}));
			}
		} else {
			# Comment line: insert as verbatim node
			$n->input($line);
			$n->comment(1);
			$graph->node_add($pos, $n);

			# Process comment, if it represents inline dtag command
			if ($line =~ /^\s*<!--\s*<dtag>(.*)<\/dtag>\s*-->\s*$/) {
				$self->do($1) if ($self->unsafe());
			}
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Insert varnames as permitted varnames
	foreach my $var (keys(%$varnames)) {
		$graph->vars()->{$var} = undef 
			if (! exists $graph->vars()->{$var});
	}

	# Close XML file
	close("XML");
	$self->cmd_return($graph);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_key.pl
## ------------------------------------------------------------

sub cmd_load_key {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $multi = shift;

	# Open tag file
	open("XML", "< $file") 
		|| return error("cannot open key-file for reading: $file");
	CORE::binmode("XML", $self->binmode()) if ($self->binmode());
	
	# Close current graph, if unmodified
	if (! $multi) {
		# Close old graph and create new graph
		$self->cmd_load_closegraph($graph);
		$graph = DTAG::Graph->new($self);
		$graph->file($file);
		push @{$self->{'graphs'}}, $graph;
		$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	}
	my @edges = ();

	# Read XML file line by line
	my $varnames = {};
	my $lineno = 0;
    while (my $line = <XML>) {
        chomp($line);
		my $n = Node->new();
		my $pos = $graph->size();

		# Record line number and source
		if ($multi) {
			++$lineno;
			$n->var('_source', "$file:$lineno");
		}

		# Process <W> tag
		if ($line =~ /^\s*<K(.*)\/>\s*/) {
			my $varstr = $1;
			my $vars = $self->varparse($graph, $varstr, 0);
			my $input = $vars->{'vim'};
			$input = $vars->{'str'} || chr($vars->{'val'} || ord('?')) 
				if (! defined($input));
			$n->input($input);
			$n->type("K");
			$graph->node_add($pos, $n);
			foreach my $var (keys(%$vars)) {
				$varnames->{$var} = 1;
				$n->var($var, $graph->xml_unquote($vars->{$var}));
			}
		} else {
			# Comment line: insert as verbatim node
			$n->input($line);
			$n->comment(1);
			$graph->node_add($pos, $n);

			# Process comment, if it represents inline dtag command
			if ($line =~ /^\s*<!--\s*<dtag>(.*)<\/dtag>\s*-->\s*$/) {
				$self->do($1) if ($self->unsafe());
			}
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Insert varnames as permitted varnames
	foreach my $var (keys(%$varnames)) {
		$graph->vars()->{$var} = undef 
			if (! exists $graph->vars()->{$var});
	}

	# Close XML file
	close("XML");
	$self->cmd_return($graph);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_lex.pl
## ------------------------------------------------------------

sub cmd_load_lex {
	my $self = shift;
	my $graph = shift;
	my $lexfile = shift;

	# Check that the lexicon is defined
	return error("No lexical database specified.") 
		if (! $self->lexicon());
	return error("Illegal lexicon file $lexfile.")
		if (! $lexfile);

	# Open lexicon file
	open("LEX", "< $lexfile") 
		|| return error("cannot open lexicon file for reading: $lexfile");
	
	# Read LEX file line by line
	print "loading lexicon...\n" if (! $self->quiet());
	my $program = "no strict;\n";
    while (my $line = <LEX>) {
		$program .= $line;
	}

	# Close LEX file
	close("LEX");

	# Evaluate lexicon file, and save it as new lexicon, if it
	# evaluates to a Lexicon object
	print "parsing lexicon...\n" if (! $self->quiet());
	my $return = eval("$program");
	print "errors = $@\n" if ($@);

	# Replace current lexicon with LexInput->lexicon()
	$self->lexicon(DTAG::LexInput->lexicon()) 
		if (DTAG::LexInput->lexicon());

	# Compile lexicon
	print "compiling lexicon...\n" if (! $self->quiet());
	$self->lexicon()->compile();

	# Return 
	return;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_malt.pl
## ------------------------------------------------------------

sub cmd_load_malt {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Open tag file
	open("MALT", "< $file") 
		|| return error("cannot open MALT-file for reading: $file");
	
	# Close current graph, if unmodified
	$self->cmd_load_closegraph($graph);

	# Create new graph
	$graph = DTAG::Graph->new($self);
	$graph->file($file);
	push @{$self->{'graphs'}}, $graph;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	$graph->vars()->{'msd'} = undef;

	# Read MALT file line by line
	my $offset = 0;
	my $edges = [];
	my $pos = 0;
    while (my $line = <MALT>) {
		# Process MALT line
        chomp($line);
		my ($input, $msd, $head, $type) = split(/	/, $line);

		# Create node and add it to graph
		my $n = Node->new();
		my $in = $graph->size();
		if ($line) {
			# Setup node
			$n->var('msd', $msd);
			$n->input($input);
			$graph->node_add($in, $n);

			# Create edge
			my $e = Edge->new();
			$e->in($in);
			$e->type($type);
			$e->out($head - 1 + $offset);
			push @$edges, $e if ($head);
		} else {
			$n->comment(1);
			$n->input('</s>');
			$offset = $graph->size();
			#$graph->node_add($in, $n);
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Add edges
	foreach my $e (@$edges) {
		$graph->edge_add($e) 
			if ($e->out() >= 0);
	}

	# Close MALT file
	close("MALT");
	$self->cmd_return($graph);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_matches.pl
## ------------------------------------------------------------

sub cmd_load_matches {
	my $self = shift;
	my $file = shift;

	# Read match file
	my $match = "";
	open("MATCH", "< $file") 
		|| return error("cannot open match-file for reading: $file");
	while(<MATCH>) {
		$match .= $_;
	}
	close("MATCH");

	# Convert match file to object, and print error messages
	my $mobj = eval("my $match");
	if ($@) {
		error($@);
	} else {
		$self->{'matches'} = $mobj;
		$self->{'match'} = 1;
	}

	# Close file
	print "opened match-file $file\n" if (! $self->quiet());

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_tag.pl
## ------------------------------------------------------------

sub cmd_load_tag {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $multi = shift;

	# Open tag file
	open("XML", "< $file") 
		|| return error("cannot open tag-file for reading: $file");
	CORE::binmode("XML", $self->binmode()) if ($self->binmode());
	
	# Close current graph, if unmodified
	if (! $multi) {
		# Close old graph and create new graph
		$self->cmd_load_closegraph($graph);
		$graph = DTAG::Graph->new($self);
		$graph->file($file);
		push @{$self->{'graphs'}}, $graph;
		$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	}
	my @edges = ();

	# Read XML file line by line
	my $varnames = {};
	my $lineno = 0;
    while (my $line = <XML>) {
        chomp($line);
		my $n = Node->new();
		my $pos = $graph->size();

		# Record line number and source
		if ($multi) {
			++$lineno;
			$n->var('_source', "$file:$lineno");
		}

		# Process <W> tag
		#if ($line =~ /^\s*<W([^>]*)>([^<]*)<\/W>\s*$/) 
		if ($line =~ /^\s*<W(.*)>(.*)<\/W>\s*$/) {
			# Input line: create node and insert it into text
			my $input = $2;
			my $varstr = $1;
			$n->input($input);
			$graph->node_add($pos, $n);

			# Parse variable string and add variables to node (and
			# variable name list)
			my $vars = $self->varparse($graph, $varstr, 0);
			foreach my $var (keys(%$vars)) {
				if ($var eq "in" || $var eq "out") {
					# Edge specification: create edge if possible
					foreach my $e (split(/\|/, $vars->{$var})) {
						$e =~ /^([+-]?[0-9]+):(\S+)$/;
						my $pos2 = $1+$pos;
						my $etype = $graph->xml_unquote($2);
						my $edge;

						# Create edge
						if ($var eq "in") {
							$edge = Edge->new($pos, $1+$pos, $etype);
						} elsif ($var eq "out") {
							$edge = Edge->new($1+$pos, $pos, $etype);
						}
						
						# Create edge if possible
						if ($pos2 < $pos) {
							$graph->edge_add($edge);
						} elsif ($pos2 == $pos && $var eq "in") {
							push @edges, $edge;
						}
					}
				} else {
					# Ordinary variable
					$varnames->{$var} = 1;
					$n->var($var, $graph->xml_unquote($vars->{$var}));
				}
			}
		} elsif ($line =~ /^\s*<!--\s*<inalign>([\d+]+)\s+([\d+]+)\s+(\S*)<\/inalign>\s*-->\s*$/) {
			# XML comment representing inalign edge
			$self->cmd_inalign($graph, $1, $2, $3);
		} else {
			# Comment line: insert as verbatim node
			$n->input($line);
			$n->comment(1);
			$graph->node_add($pos, $n);

			# Process comment, if it represents inline dtag command
			if ($line =~ /^\s*<!--\s*<dtag>(.*)<\/dtag>\s*-->\s*$/) {
				$self->do($1) if ($self->unsafe());
			}
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Insert varnames as permitted varnames
	foreach my $var (keys(%$varnames)) {
		$graph->vars()->{$var} = undef 
			if (! exists $graph->vars()->{$var});
	}

	# Insert unprocessed edges
	foreach my $e (@edges) {
		# Insert edge unless it already exists
		$graph->edge_add($e, 1);
	}

	# Close XML file
	close("XML");
	$self->cmd_return($graph);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_load_tiger.pl
## ------------------------------------------------------------

my ($TIGER_COMMENT, $TIGER_NT, $TIGER_T) = (0, 1, 2);

sub cmd_load_tiger {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Close current graph, if unmodified
	$self->cmd_load_closegraph($graph);

	# Create new graph
	$graph = DTAG::Graph->new($self);
	$graph->file($file);
	push @{$self->{'graphs'}}, $graph;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# Inform user about action
	print "Importing data from TIGER XML file $file\n" 
		if (!  $self->quiet());

	# Head edge
	my $HEADEDGE = "--??";

	# Determine whether graph is a dependency graph
	my $vars = {};
	my $etypes = {};
	my $nodes = {};
	my $edges = [];
	my $terminals = {};
	my $nonterminals = {};
	my @newnodes = ();
	my $parents = {};
	my $heads = {};
	my $visited = {};
	my ($parent, $parentid, $ntid, $head, $headid);

	# Create parser object

		# Start tag handler
		my $handle_start = sub { 
			my $expat = shift;
			my $tag = lc(shift);

			# Sentence <s> tag: create comment node
			if ($tag eq 's') {
				@newnodes = ();
				$terminals = {};
				$nonterminals = {};
				$parents = {};
				$heads = {};
				$graph->node_add("", 
					xml2node($vars, $TIGER_COMMENT, 's', @_));
			}

			# Terminal <t> or non-terminal <nt> tag: record node
			if ($tag eq 'nt' || $tag eq 't') {
				# Create node
				my $node = xml2node($vars, 
					(($tag eq 't') ?  $TIGER_T : $TIGER_NT), 
					$tag, @_);

				# Register id of node and store id of nt-node for primary edges
				my $id = $node->var('id');
				if ($tag eq 't') {
					$terminals->{$id} = $node;
					push @newnodes, $node;
				} elsif ($tag eq 'nt') {
					$nonterminals->{$id} = $node;
				}
				$ntid = $id if ($tag eq 'nt');
			}

			# Edge <edge> tag or secondary edge <secedge> tag
			if ($tag eq 'edge' || $tag eq 'secedge') {
				my $edge = xml2edge($etypes, $ntid, @_);
				push @$edges, $edge;

				# Record parent and lexical head
				if ($tag eq 'edge') {
					# Record parent
					$parents->{$edge->in()} = $edge->out();

					# Record lexical head
					if ($edge->type() eq $HEADEDGE) {
						$heads->{$edge->out()} = $edge->in();
					}
				}
			}
		};

		# End tag handler
		my $handle_end = sub {
			my $expat = shift;
			my $tag = shift;

			# Sentence </s> tag: create comment node
			if ($tag =~ /^(s|S)$/) {
				# Add terminals and non-terminals to graph in top-down
				# left-right order
				while (@newnodes) {
					my $top = shift(@newnodes);
					my $id = $top->var('id') || "";

					# Skip node if it has already been added
					next() if ($nodes->{$id});

					# Process parent node first, if it exists
					if (defined($parentid = $parents->{$id})) {
						# Check that parent id refers to a real node,
						# and that it hasn't already been added to the graph,
						# and that the parent node does not correspond
						# to a terminal, if we are creating a
						# dependency graph
						if (defined($parent = $nonterminals->{$parentid})
								&& (! defined($nodes->{$parentid}))
								&& ! (defined($heads->{$parentid}))) {
							# Add parent and top node to list, and
							# process next node, if parent node has
							# not been visited before
							if (! $visited->{$parentid}) {
								$visited->{$parentid} = 1;
								unshift @newnodes, $parent, $top;
								next();
							}
						}
					}

					# Add top node to graph if it is non-terminal or
					# terminal without a $HEADEDGE parent
					if (defined($nonterminals->{$id})) {
						# Add any non-terminal node without $HEADEDGE
						# child to graph
						$nodes->{$id} = $graph->size();
						$graph->node_add("", $top);
					} else {
						# Terminal: copy features from $HEADEDGE parent first
						$parentid = $parents->{$id};
						if (defined($parentid) 
								&& ($heads->{$parentid} || "") eq $id) {
							# Copy features
							$parent = $nonterminals->{$parentid};
							foreach my $var (keys(%$vars)) {
								if (! defined($top->var($var))) {
									$top->var($var, $parent->var($var) || "");
								}
							}

							# Let parent id refer to non-terminal
							$nodes->{$parentid} = $graph->size();
						}

						# Add terminal to graph
						$nodes->{$id} = $graph->size();
						$graph->node_add("", $top);
					}
				}

				# Add edges to graph
				my $unresolved = [];
				foreach my $e (@$edges) {
					# Add edge to graph, or store it for later processing
					my $in = $nodes->{$e->in()};
					my $out = $nodes->{$e->out()};
					my $type = $e->type();
					if (defined($in) && defined($out)) {
						# Nodes exist: add edge to graph
						$e->in($in);
						$e->out($out);
						$graph->edge_add($e) 
							if ($in != $out);
					} else {
						# Nodes did not both exist: store as unresolved
						push @$unresolved, $e;
					}
				}
				$edges = $unresolved;

				# Create comment node
				$graph->node_add("", xml2node($vars, 0, '/s', @_));
			}
		};

	# Create XML parser
	my $xmlparser = $self->{'xmlparser'} 
		= new XML::Parser(
			'Handlers' =>
			{	'Start' => $handle_start, 
				'End' => $handle_end 
			});

	# Parse file
	open(XML, "<$file") 
		|| return error("cannot open TIGER XML file for reading: $file");
	eval('$xmlparser->parse(*XML)');
	print "errors = $@\n" if ($@);
	close(XML);

	# Insert names in $vars as permitted variable names
	foreach my $var (keys(%$vars)) {
		$graph->vars()->{$var} = undef;
	}

	# Warn about unresolved edges
	my $warn = "failed to resolved following edges:\n";
	foreach my $e (@$edges) {
		# Compute incoming and outgoing node
		$warn .= "\t" . ($e->out() || "?") . " --" . ($e->type() || "?")
			. "--> " . ($e->in() || "?") . "\n";
	}

	# Update graph
	$self->cmd_return();

	# Return
	return 1;
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_lookup.pl
## ------------------------------------------------------------

sub cmd_lookup {
	my $self = shift;
	my $graph = shift;
	my $input = shift;

	my $lexicon = $self->lexicon();
	my @types = sort {$a->[0] cmp $b->[0] || $a->[1] cmp $b->[1]} 
		@{$lexicon->lookup(lc($input))};
	print "input = $input\n" . "matches = " . join(" ", 
		map {$_->[0] . "/" . $_->[1]} @types) . "\n";
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_lookup_align.pl
## ------------------------------------------------------------

sub cmd_lookup_align {
	my $self = shift;
	my $graph = shift;
	my $input = shift;

	# Exit if no alignment lexicon
	my $alexicon = $graph->alexicon();
	if (! $alexicon) {
		error("no alignment lexicon in current alignment");
		return 1;
	}

	# Extract node
	my $outkey = "a";
	my $inkey = "b";
	my $matchout = "0";
	my $matchin = "0";
	my $outgraph = $graph->graph($outkey);
	my $ingraph = $graph->graph($inkey);
	my $outnode = 0;
	my $innode = 0;

	if ($input =~ /^\s*([a-z])(-?[0-9]+)\s*$/) {
		my $key = $1;
		my $node = $graph->rel2abs($key, $2);
		my $node2 = 0;
		my $keygraph = $graph->graph($key);

		# Find nearest edge
		for (my $d = 0; $d < $keygraph->size(); ++$d) {
			my $k1 = max(0, $node - $d);
			my $k2 = min($node + $d, $keygraph->size() - 1);

			my @nodes = grep {$_->outkey() ne $key || $_->inkey() ne $key}
				@{$graph->node($key, $k1)};
			if (@nodes) {
				foreach my $node (@nodes) {
					$node2 += ($node->outkey() ne $key)
						? $node->outArray()->[0] 
						: $node->inArray()->[0];
				}
				$node2 = int($node2 / scalar(@nodes));
				last();
			}
		}

		# Set $outnode, $innode
		$outnode = ($outkey eq $key) ? $node : $node2;
		$innode = ($inkey eq $key) ? $node : $node2;
		$matchout = ($outkey eq $key) ? 1 : 0;
		$matchin = ($inkey eq $key) ? 1 : 0;
	} elsif ($input =~ /^\s*([a-z])(-?[0-9]+)\s+([a-z])(-?[0-9]+)$/) {
		$outkey = $1;
		$outnode = $graph->rel2abs($outkey, $2);
		$inkey = $3;
		$innode = $graph->rel2abs($inkey, $4);
		$matchout = 1;
		$matchin = 1;
	} else {
		return 1;
	}

	# Find window
	my $o1 = max(0, $outnode - $alexicon->window());
	my $o2 = min($outgraph->size() - 1, $outnode + $alexicon->window());
	my $i1 = max(0, $innode - $alexicon->window());
	my $i2 = min($ingraph->size() - 1, $innode + $alexicon->window());

	# Find all nodes within window
	my $unaligned_out = [];
	for (my $o = $o1; $o <= $o2; ++$o) {
		push @$unaligned_out, $o
			if (! $outgraph->node($o)->comment());
	}

	# Find unaligned nodes in ingraph
	my $unaligned_in = [];
	for (my $i = $i1; $i <= $i2; ++$i) {
		push @$unaligned_in, $i
			if (! $ingraph->node($i)->comment());
	}

	# Lookup all alexes containing unaligned words
	my $unaligned_outw = [
		map {$outgraph->node($_)->input()} @$unaligned_out ];
	my $unaligned_inw = [
		map {$ingraph->node($_)->input()} @$unaligned_in ];
	my $alexes = $alexicon->lookup_words($unaligned_outw, $unaligned_inw);
	
	# Generate all possible edges within window
	my $edges = [];
	foreach my $alex (@$alexes) {
		#print "\n" . $alex->string() . "\n";

		# Find matching nodes in in- and out-graphs
		my $inmatches = $alexicon->match_pattern($ingraph, 
			$unaligned_in, $alex->in());
		my $outmatches = $alexicon->match_pattern($outgraph,
			$unaligned_out, $alex->out());

		# Create matching edges
		if (@$outmatches && @$inmatches) {
			my $str = $alex->string() . " : ";
			$str .= "$outkey" . join("|$outkey", 
				map {join("+$outkey", map {$graph->abs2rel($outkey, $_)} @$_)} 
					@$outmatches);
			$str .= "  $inkey" . join("|$inkey", 
				map {join("+$inkey", map {$graph->abs2rel($inkey, $_)} @$_)} 
					@$inmatches) . " \n";

			# Match string
			my $nout = $graph->abs2rel($outkey, $outnode);
			my $nin = $graph->abs2rel($inkey, $innode);
			print $str if (($matchout && $str =~ /$outkey$nout[| +]/)
				|| ($matchin && $str =~ /$inkey$nin[| +]/));
		}
	}

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_lookupw.pl
## ------------------------------------------------------------

sub cmd_lookupw {
	my $self = shift;
	my $graph = shift;
	my $input = shift;

	my $lexicon = $self->lexicon();
	my @types = @{$lexicon->lookup_word(lc($input))};
	print "input = $input\n" . "matches = " . join(" ", @types) . "\n";
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_macro.pl
## ------------------------------------------------------------

sub cmd_macro {
	my $self = shift;
	my $name = shift;
	my $command = shift;

	# Add/delete macro
	if ($command) {
		$self->{'macros'}{$name} = $command;
	} else {
		delete $self->{'macros'}{$name};
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_macros.pl
## ------------------------------------------------------------

sub cmd_macros {
	my $self = shift;
	my $name = shift;
	my $command = shift;

	# Print macros
	foreach my $m (sort(keys(%{$self->{'macros'}}))) {
		print "macro[$m]: " . $self->{'macros'}{$m} . "\n";
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_maptags.pl
## ------------------------------------------------------------

sub cmd_maptags {
	my $self = shift;
	my $graph = shift;
	my $mapfile = shift;
	my $invar = shift;
	my $outvar = shift;

	# Check that arguments are legal
	if (! (defined($invar) && defined($outvar))) {
		error("Usage: maptags [-map $mapfile] $invar $outvar\n");
	}

	# Read mapfile
	my $map = $self->{'maptags_map'} 
		= $self->{'maptags_map'} || {};
	my $missing = $self->{'maptags_missing'} 
		= $self->{'maptags_missing'} || {};
 
	if ($mapfile && -f $mapfile) {
		open(IFS, "<$mapfile") 
			|| return error("cannot open mapfile $mapfile");
		while (my $line = <IFS>) {
			chomp($line);
			my ($in, $out) = split(/\t/, $line);
			$map->{$in} = $out;
		}
		close(IFS);
	}

	# Convert words in graph
	for (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		if (! $node->comment()) {
			my $inval = $node->var($invar);
			next() if (! defined $inval);
			my $instring = lc($node->input());
			my $outval = $map->{$inval . ":" . $instring} || $map->{$inval};
			if (defined $outval) {
				$node->var($outvar, $outval);
			} else {
				$missing->{$inval} = 1;
			}
		}
	}

	# Add new var to vars
	$self->cmd_vars($graph, $outvar);

	# Print input values that lack from map
	print "Undefined input tags: "
		. join(" ", sort(keys(%$missing))) . "\n";

	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_matches.pl
## ------------------------------------------------------------

sub cmd_matches {
	my $self = shift;
	my $cmd = shift;

	# Process options
	my $options = {};
	my @stats = ();
	my $sort = 1;
	while ($cmd) {
		if ($cmd =~ s/^-nomatch//) {
			$options->{'nomatch'} = 1;
		} elsif ($cmd =~ s/^-nokey//) {
			$options->{'nokey'} = 1;
		} elsif ($cmd =~ s/^-notext//) {
			$options->{'notext'} = 1;
		} elsif ($cmd =~ s/^-stats\(\s*(key|text)\s*\)//) {
			@stats = ($1);
		} elsif ($cmd =~ s/^-stats\(\s*(key|text)\s*,\s*(key|text)\)//) {
			@stats = ($1, $2);
		} elsif ($cmd =~ s/^-a(lpha)?//) {
			$sort = ($sort > 0) ? 1 : -1;
		} elsif ($cmd =~ s/^-n(um)?//) {
			$sort = ($sort > 0) ? 2 : -2;
		} elsif ($cmd =~ s/^-r(everse)?//) {
			$sort = - $sort;
		} elsif ($cmd =~ s/^-p(rint)?(=([0-9]+))?//) {
			$options->{'print'} = (defined($3) ? $3 : 20);
		} else {
			$cmd =~ s/^.//;
		}
	}

	# Print all matches or all statistics
	my $matches = $self->{'matches'};
	my $sorthash = {};
	my $count = {};
	my ($key1, $key2, $list, $hash);
	my $i = 0;
	foreach my $f (sort(keys(%$matches))) {
		foreach my $m (@{$matches->{$f}}) {
			++$i;
			if (! @stats) {
				# Print match
				if (defined($options->{'print'})) {
					my $window = $options->{'print'};
					my $i1 = 1e30;
					my $i2 = -1e30;
				    my @vars = sort(grep {substr($_, 0, 1) eq '$'} keys(%$m));
					map {
						my $v = $m->{$_}; 
						$i1 = $v if ($v < $i1); 
						$i2 = $v if ($v > $i2)
					} @vars;
					$self->goto_match($i);
					print "\n\t" . $self->graph()->words($i1 - $window, $i2 +
						$window, " ") . "\n\n"; 
				} else {
					print $self->print_match($i, $f, $m, $options);
				}
			} else {
				# Sort matches
				$key1 = $m->{$stats[0]} || "";

				# Find array stored in sorted hash
				if (scalar(@stats) == 1) {
					$list = $sorthash->{$key1} 
						= ($sorthash->{$key1} || []);
				} else {
					$key2 = $m->{$stats[1]} || "";
					$list = $sorthash->{$key1}{$key2} 
						= ($sorthash->{$key1}{$key2} || []);
				}

				# Push current match onto list
				++$count->{$key1};
				push @$list, $i;
			}

			# Abort if requested
			return 1 if ($self->abort());
		}
	}

	# Print statistics
	if (@stats) {
		# Define sorting and count subroutines
		my $cntsub1 = sub {
			my $hash = shift; my $count = shift; my $key = shift; 
			return $count->{$key} || 0; 
		};
		my $cntsub2 = sub {
			my $hash = shift; my $count = shift; my $key = shift; 
			return scalar(@{$hash->{$key}});
		};

		# Sorting procedure
		sub sort_hash {
			my $hash = shift;
			my $count = shift;
			my $sort = shift; # 1/-1=alpha, 2/-2=num, -1,-2=reverse
			my $cntsub = shift;

			# Sort hash
			my @sorted;
			if (abs($sort) == 1) {
				@sorted = sort { $a cmp $b } 
					keys(%$hash);
			} else {
				@sorted = sort { &$cntsub($hash, $count, $a) 
						<=> &$cntsub($hash, $count, $b) || $a cmp $b }
					keys(%$hash);
			}

			# Reverse list, if required
			return ($sort < 0) ? reverse(@sorted) : @sorted;
		}

		# Print all primary and secondary keys
		foreach $key1 (sort_hash($sorthash, $count, $sort, $cntsub1)) {
			printf '%4d: %s' . "\n", $count->{$key1}, $key1;

			if (scalar(@stats) == 1) {
				# One key
				print " " x 6 . "M" . join(" M", @{$sorthash->{$key1}}) . "\n"
					if (! $options->{'nomatch'});
			} else {
				# Two keys
				#foreach $key2 (keys(%{$sorthash->{$key1}})) {
				foreach $key2 (sort_hash($sorthash->{$key1}, $count, 
						$sort, $cntsub2)) {
					$list = $sorthash->{$key1}{$key2};
					printf '%8d: %s' . "\n", scalar(@$list), $key2;
					print " " x 10 . "M" . join(" M", @$list) . "\n"
						if (! $options->{'nomatch'});
				}
			}
		}
	}

	# Return
	return 1;
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_merge.pl
## ------------------------------------------------------------

sub cmd_merge {
	my $self = shift;
	my $oldgraph = shift;
	my $files = shift;

	# Load all files and compute reliability scores
	my $graphs = [];
	foreach my $file (glob($files)) {
		# Load file
		print "Loading $file\n";
		$self->cmd_load(DTAG::Graph->new($self), undef, $file);
		push @$graphs, $self->graph();
	}

	# Create new graph
	$self->cmd_new();
	my $graph = $self->graph();

	# Create nodes in new graph
	$self->merge_nodes($graph, $graphs);

	# Create edges in new graph
	$self->merge_edges($graph, $graphs);

	# Return
	return 1;
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_move.pl
## ------------------------------------------------------------

sub cmd_move {
	my $self = shift;
	my $graph = shift;
	my $fromr = shift;
	my $tor = shift;

	# Compute absolute positions
	my $from = (! defined($fromr) || $fromr eq "")
		? $graph->size() :  ($fromr || 0) + $graph->offset();
	my $to = (! defined($tor) || $tor eq "")
		? $graph->size() :  ($tor || 0) + $graph->offset();

	# Find node object
	my $node = $graph->node($from);
	return error("Non-existent node: $from") 
		if ((! defined($from)) || (! ref($node)));
	
	# Save edges and delete node
	my $edges = [@{$node->in()}, @{$node->out()}];
	$self->cmd_del($graph, $from);

	# Add node to graph again at new place
    $graph->node_add($to, $node);

	# Reconstruct edges
	foreach my $edge (@$edges) {
		$edge->in(node_moved($edge->in(), $from, $to));
		$edge->out(node_moved($edge->out(), $from, $to));
		$graph->edge_add($edge);
	}

	# Recompile node ids
	$graph->compile_ids();

	# Mark graph as modified
    $graph->mtime(1);

	# Return
	return 1;
}

sub node_moved {
	my $n = shift;
	my $from = shift;
	my $to = shift;

	# Compute position of moved node
	if ($n == $from) {
		return $to;
	} 
	
	# Compute position of any other node in two steps
	my $n1 = ($n > $from) ? $n - 1 : $n;
	my $n2 = ($n1 >= $to) ? $n1 + 1 : $n1;
	return $n2;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_new.pl
## ------------------------------------------------------------

sub cmd_new {
	my $self = shift;

	# Create new graph
	push @{$self->{'graphs'}}, DTAG::Graph->new($self);

	# Set graph pointer to new graph
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# Update viewer
	$self->cmd_return($self->graph());

	# Return 
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_node.pl
## ------------------------------------------------------------

sub cmd_node {
	my $self = shift;
	my $graph = shift;
	my $posr  = shift;
	my $input = shift;
	my $varstr = shift;

	# Check node -off
	return error("node creation blocked") 
		if ($graph->{'block_nodeadd'});

	# Check range
	my $pos = (! defined($posr) || $posr eq "") 
		? $graph->size()
		:  ($posr || 0) + $graph->offset(); 

	# Create new node
	my $N = Node->new();
	$N->input($input);

	# Parse variable specification
	my $vars = $self->varparse($graph, $varstr, 1);
	foreach my $var (keys %$vars) {
		$N->var($var, $vars->{$var}) if (defined($vars->{$var}));
	}

	# Add new node to graph, and mark graph as modified
	$graph->node_add($pos, $N);

	# Mark graph as modified
	$graph->mtime(1);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_noedge.pl
## ------------------------------------------------------------

sub cmd_noedge {
	my $self = shift;
	my $graph = shift;
	my $nodeinr = shift;

	# Apply offset
	my $nodein = defined($nodeinr) ? $nodeinr + $graph->offset() : undef;

	# Check that $nodein is valid
	my $nin  = $graph->node($nodein);
	return error("Non-existent node: $nodeinr") 
		if ((! defined($nodein)));

	# Delete in-edges in $nodein (and out-edges, if $nodein is deleted)
	my @edges = (@{$nin->in()});
	foreach my $e (@edges) {
		# Delete edge if it matches description
		$graph->edge_del($e) 
	}

	# Mark graph as modified
    $graph->mtime(1);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_noerror.pl
## ------------------------------------------------------------

sub cmd_noerror {
	my $self = shift;
	my $graph = shift;
	my $noder = shift;
	my $error = shift;
	$error = "" if (! defined($error));

	# Apply offset
	my $node = defined($noder) ? $noder + $graph->offset() : undef;

	# Find node 
	my $N = $graph->node($node);

	# Errors: non-existent node, or comment node
	return error("Non-existent node: $noder") if (! $N);
	return error("Node $noder is a comment node.") if ($N->comment());

	# Set values for all given variable-value pairs
	$graph->vars()->{"_noerror"} = undef;
	$N->var("_noerror", ":" . $error . ":");
	$graph->mtime(1);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_note.pl
## ------------------------------------------------------------

sub cmd_note {
	my $self = shift;
	my $graph = shift;
	my $noder = shift;
	my $note = shift;

	# Check that graph is a dependency graph
	if (! UNIVERSAL::isa($graph, 'DTAG::Graph')) {
		error("ERROR: Notes not supported for alignments\n");
		return 1;
	}

	# Find absolute node
	my $node = defined($noder) ? $noder + $graph->offset() : undef;
	my $N = $graph->node($node);

	# Errors: non-existent node, or comment node
	return error("Non-existent node: $noder") if (! $N);
	return error("Node $noder is a comment node.") if ($N->comment());

	# Clean up note
	$note =~ s/"/&quot;/g;
	$note =~ s/</&lt;/g;
	$note =~ s/</&gt;/g;

	# Set values for all given variable-value pairs
	$graph->vars()->{'note'} = 1;
	$N->var("note", $note);
	$graph->mtime(1);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_notes.pl
## ------------------------------------------------------------

sub cmd_notes {
	my ($self, $graph) = @_;
	my $imin = $graph->var("imin");
	my $imax = $graph->var("imax");
	
	$imin = 0 if ($imin < 0);
	$imax = $graph->size() if ($imax < 0 || $imax > $graph->size());
	for (my $i = $imin; $i < $imax; ++$i) {
		my $note = ($graph->node($i)->var("note") || "") . "";
		$note =~ s/\&quot;/"/g;
		$note =~ s/\&lt;/</g;
		$note =~ s/\&gt;/>/g;

		print "NOTE[" . ($i - $graph->offset()) . "]: " . $note .  "\n\n"
			if ($note);
	}
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_offset.pl
## ------------------------------------------------------------

sub cmd_offset {
	my $self = shift;
	my $graph = shift;
	my $sign = shift || "+";
	my $number = shift || "0";

	if ($number eq "end") {
		$number = $graph->size();
	}

	# Set new offset
	if ($sign eq "+") {
		$graph->offset($graph->offset() + $number);
	} elsif ($sign eq "-") {
		$graph->offset($graph->offset() - $number);
	} elsif ($sign eq "=") {
		$graph->offset($number);
	}

	# Report offset
	print "Offset: " . $graph->offset() . "\n" if (! $self->quiet());

	# Return with success
	return 1;
}

sub pos2apos {
	my $graph = shift;
	my $pos = shift;

	# Decompose position
	$pos =~ /^([+-=])?([0-9]+)$/;

	# Calculate absolute position
	if ($1 eq "+") {
		return $graph->offset() + $2;
	} elsif ($1 eq "-") {
		return $graph->offset() - $2;
	} elsif ($1 eq "=") {
		return $2;
	}
}	

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_offset_align.pl
## ------------------------------------------------------------

sub cmd_offset_align {
	my $self = shift;
	my $graph = shift;
	my $offsets = shift;

	# Check for auto offset
	if ($offsets eq "auto") {
		$graph->auto_offset();
		return 1;
	}

	# Process offsets
	while ($offsets =~ s/^\s+([-+=])?([a-z])(-?[0-9]+)//) {
		# Find sign, key, and number
		my $sign = $1 || "+";
		my $key = $2;
		my $number = 0 + ($3 || 0);

		# Set new offset
		if ($sign eq "+") {
			$graph->offset($key, $graph->offset($key) + $number);
		} elsif ($sign eq "-") {
			$graph->offset($key, $graph->offset($key) - $number);
		} elsif ($sign eq "=") {
			$graph->offset($key, $number);
		}

		# Check that offset is valid
		$graph->offset($key, 0) if ($graph->offset($key) < 0);

		# Set imin accordingly
		$graph->{'imin'}{$key} = $graph->offset($key);
	}

	# Report offsets
	print "offset " . 
		join(" ",
			map {"=$_" . $graph->offset($_)}
			sort(keys(%{$graph->{'graphs'}})))
		. "\n" if (! $self->quiet());


	# Update graph
	$self->cmd_return($graph);

	# Return with success
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_ok.pl
## ------------------------------------------------------------

sub cmd_ok {
	my $self = shift;
	my $graph = shift;

	# Accept automatic alignment
	if (UNIVERSAL::isa($graph, 'DTAG::Alignment') && $graph->ok()) {
		$self->cmd_return($graph);
	} else {
		error("no learner associated with current graph");
	} 

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_option.pl
## ------------------------------------------------------------

sub cmd_option {
	my $self = shift;
	my $option = shift;
	my $value = shift;
	$value =~ s/\s*$// if (defined($value));

	if (defined($value)) {
		# Set option (if value given)
		$self->option($option, $value);
	} elsif ($option eq "*") {
		foreach my $opt (sort(keys(%{$self->{"options"}}))) {
			$self->cmd_option($opt);
		}
	} else {
		# Print option
		$value = $self->option($option);
		$value = 'undef' if (! defined($value));
		print "option $option=", $value, "\n";
	}

	# Exit
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_output.pl
## ------------------------------------------------------------

sub cmd_output {
	my $self = shift;
	$self->var('output', @_);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_parse.pl
## ------------------------------------------------------------

sub cmd_parse {
	my $self = shift;
	my $graph = shift;
	my $cmd = shift;

	# Create input object
	my $input = undef; 
	if ($cmd) {
		# Text input: unsegmented string
		$input = Text->new();
		$input->input('', $cmd);
	} else {
		# Graph input: segmented string
		$input = $graph;
	}

	# Create new parse object
	my $parse = DTAG::Parse->new();
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_parse2dtag.pl
## ------------------------------------------------------------

sub cmd_parse2dtag {
	my $self = shift;
	my $ifile = shift;
	my $ofile = shift;

	# Open input file
	open("SCRIPT", "< $ifile")
		|| return error("cannot open file for reading: $ifile");
	
	# Read script file line by line, and add to "line"
	my $n = 0;
	my $step = 0;
	my $lines = [];
	my $steps_hash = {};
	my $lines_hash = {};
	my $multi = 0;
	while (my $line = <SCRIPT>) {
		if ($line =~ /^\s*multi\s+([0-9]+)\s*$/) {
			++$step;
			$multi = $1;
		} elsif ($line =~ /^\s*(edge\s+)?([0-9]+)\s+(\S+)\s+([0-9]+)\s*$/) {
			# Edge addition
			if ($multi > 0) {
				--$multi;
			} else {
				++$step;
			}
			push @$lines, ["edge", $2, $3 . ":$step", $4, "\n"];
			$lines_hash->{"$2 $3 $4"} = $#$lines;
			$steps_hash->{"$2 $3 $4"} = $step;
		} elsif ($line =~ /^\s*del\s+([0-9]+)\s+(\S+)\s+([0-9]+)\s*$/) {
			# Edge deletion
			if ($multi > 0) {
				--$multi;
			} else {
				++$step;
			}
			my $edgeline = $lines_hash->{"$1 $2 $3"};
			my $edgestep = $steps_hash->{"$1 $2 $3"};
			push @$lines, ["# undo " . ($step || "?") . ":", $line];
			if ($edgeline) {
				$lines->[$edgeline][2] .= "-$step";
			}
		} else {
			push @$lines, [$line];
		}

		# Increment line counter
		++$n;
	}

	# Close input
	close("SCRIPT");

	# Print output
	open("SCRIPT", "> $ofile")
		|| return error("cannot open file for writing: $ofile");
	foreach my $line (@$lines) {
		print SCRIPT join(" ", @$line);
	}
	close("SCRIPT");
	
	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_partag.pl
## ------------------------------------------------------------

sub cmd_partag {
	my $self = shift;
	my $alignment = shift;
	my $tkey = shift;

    # Check that $graph is an Alignment
    if (! UNIVERSAL::isa($alignment, 'DTAG::Alignment')) {
        error("no active alignment");
        return 1;
    }

	# Find source and target graphs
	my $skey = [grep {$_ ne $tkey} keys(%{$alignment->graphs()})]
		->[0];
	my $source = $alignment->graph($skey);
	my $target = $alignment->graph($tkey);
	print "target graph = " . $target->file() . "\n";
	print "source graph = " . $source->file() . "\n";
	

	# TRANSFER DEPENDENCIES FROM SOURCE TO TARGET
    my $n = $source->size();
	my $scount = 0;
	my $tcount = 0;
    for (my $i = 0; $i < $n; ++$i) {
        # Find node and skip if comment
        my $node = $source->node($i);
        next() if $node->comment();
        foreach my $e (@{$node->in() || []}) {
			# Find edge parameters
			++$scount;
			my $type = $e->type();
			my $sin = $e->in();
			my $sout = $e->out();

			# Find alignment edges for $sin and $sout
			my $inalign = $alignment->edge(
				$alignment->node_edges($skey, $sin)->[0]);
			my $outalign = $alignment->edge(
				$alignment->node_edges($skey, $sout)->[0]);
			next() if (! (defined($inalign) && defined($outalign)));

			# Create list with potential target edges
			my $tedges = [];
			print "$skey$sin(" . $inalign->string() . ")" 
				. " $type " 
				. "$skey$sout(" .  $outalign->string() . ")" . "\n";

			# 1. Add target edge A' -{r}-> B' given source
			# edge A -{r}-> B and alignments A -- A' and B -- B'
			if (($inalign->signature() eq $skey . "1" . $tkey . "1")
					&& ($outalign->signature() eq $skey . "1" . $tkey . "1")) {
				push @$tedges,
					Edge->new($inalign->inArray()->[0],
						$outalign->inArray()->[0],
						$type);
			}

			# Print created edges
			foreach my $e (@$tedges) {
				print "    " . $e->print() . "\n";
				$target->edge_add($e);
				++$tcount;
			}
        }
    }

	# Print debugging
	print "Converted $scount source edges into $tcount target edges\n";

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_patch.pl
## ------------------------------------------------------------

sub cmd_patch {
	my $self = shift;
	my $graph = shift;
	my $key = shift;
	my $difffile = shift;

	# print "patch $key : $difffile\n";

	sub usage {
		print "Usage: use one of the two following patch commands:\n";
		print '    patch $difffile          (for graphs)', "\n";
		print '    patch -$key $difffile    (for alignments)', "\n";
	}

	# Check that diff-file exists
	my $diff;
	if (! -f "$difffile" ) {
		print "ERROR: Cannot open diff-file $difffile for reading\n";
		usage();
		return 1;
	}

	if (UNIVERSAL::isa($graph, 'DTAG::Graph')) {
		# Patch graph: Check arguments
		if (defined($key)) {
			print "ERROR: Key arguments cannot be used with graphs.\n";
			usage();
			return 1;
		}

		# Read diff file
		$diff = $self->read_tagdiff($graph, $difffile);	

		# Apply patch
		$self->cmd_patch_graph($graph, $diff);
		print "patched current graph with diff-file $difffile\n";
	} else {
		# Patch alignment: Check arguments
		if (! defined($key)) {
			print "ERROR: You need to supply a key argument.\n";
			usage();
			return 1;
		}

		# Read diff file
		my $keygraph = $graph->graph($key);
		if (! defined($keygraph)) {
			print "ERROR: Cannot find graph in aligment associated with key $key.\n";
		}
		$diff = $self->read_tagdiff($keygraph, $difffile);	

		#print "diff:\n";
		#foreach my $d (@$diff) {
		#	print join("\n", join(" ", @{$d->[0]}), 
		#		join("\n", map {"a: " . $_->xml($keygraph)} @{$d->[1]}),
		#		"---", join("\n", map {"b: " . $_->xml($keygraph)} @{$d->[2]}), "==="), "\n";
		#}

		# Patch alignment
		$self->cmd_patch_graph($keygraph, $diff);
		$self->cmd_patch_alignment($graph, $keygraph, $diff, $key);
		print "patched current alignment with diff-file $difffile for key \"" .  ($key || "") . "\"\n";
	}

	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_patch_alignment.pl
## ------------------------------------------------------------

sub cmd_patch_alignment {
	my $self = shift;
	my $alignment = shift;
	my $graph = shift;
	my $diff = shift;
	my $key = shift;
	$graph->offset(0);
	
	# Compute word mapping by processing diff commands
	my $wordmap = {};
	my $i = 0;
	my $imax = $graph->size() - 1;
	my $offset = 0;
	foreach my $spec (@$diff) {
		# Read command
		my ($cmd, $a, $b) = @$spec;
		my ($o, $a1, $a2, $b1, $b2) = @$cmd;

		# Move counter $i forward to $a1
		for ( ; $i < $a1; ++$i) {
			$wordmap->{$i} = $i + $offset;
		}
		$i = $a2;
		$offset += ($b2-$b1)-($a2-$a1);
	}
	for ( ; $i <= $imax; ++$i) {
		$wordmap->{$i} = $i + $offset;
	}

	# Adjust edges in alignment
	my $edges = $alignment->edges();
	my @newedges = ();
	for (my $i = 0; $i < scalar(@$edges); ++$i) {
		my $edge = $edges->[$i];

		# Adjust in-nodes
		my $skip = 0;
		my $newedge = $edge->clone();
		if ($edge->inkey() eq $key) {
			my $array = patchAlignmentArray($wordmap, $edge->inArray());
			$newedge->inArray($array);
			$skip = 1 if (! defined($array));
		}

		if ($edge->outkey() eq $key) {
			my $array = patchAlignmentArray($wordmap, $edge->outArray());
			$newedge->outArray($array);
			$skip = 1 if (! defined($array));
		}
		push @newedges, $newedge if (! $skip);
	}

	# Delete edges
	for (my $i = $#$edges; $i >= 0; --$i) {
		$alignment->del_edge($i);
	}

	# Add edges
	foreach my $e (@newedges) {
		$alignment->add_edge($e);
	}
}


sub patchAlignmentArray {
	my $wordmap = shift;
	my $array = shift;
 	my $newarray = [];
	for (my $i = 0; $i < scalar(@$array); ++$i) {
		my $pos = $array->[$i];
		my $newpos = $wordmap->{$pos};
		push @$newarray, $newpos;
		return undef if (! defined($newpos));
	}
	return $newarray;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_patch_graph.pl
## ------------------------------------------------------------

sub cmd_patch_graph {
	my $self = shift;
	my $graph = shift;
	my $diff = shift;
	my $oldoffset = $graph->offset();
	$graph->offset(0);
	
	# Process diff commands
	my $offset = 0;
	foreach my $spec (@$diff) {
		# Read command
		my ($cmd, $a, $b) = @$spec;
		my ($o, $a1, $a2, $b1, $b2) = @$cmd;

		# Delete nodes
		if ($o eq "c" || $o eq "d") {
			#print "delete nodes from " . ($a1+$offset) 
			#	. " to " . ($a2 + $offset) . "\n";
			my $o = $offset;
			for (my $i = $a2 - $a1 - 1; $i >= 0; --$i) {
				# Compare input
				my $pos = $i + $a1 + $o;
				my $n = $graph->node($pos);
				#print "    delete word $pos at index $i ("
				#	. $n->input() . "/" . $a->[$i]->input() . ")\n";

				# Check input
				if ($n->input() ne $a->[$i]->input()) {
					print "ERROR: Expected word " . $a->[$i]->input()
						. " but found word " . $n->input() . "\n";
				}
				
				# Delete node
				$self->cmd_del($graph, $pos);
				--$offset;
			}	
		} 
		
		# Add nodes
		if ($o eq "c" || $o eq "a") {
			#print "add nodes from $b1 to $b2\n"; 
			for (my $i = 0; $i < $b2-$b1; ++$i) {
				my $n = $graph->node_add($b1+$i, $b->[$i]);
				++$offset;
			}
		}
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_pause.pl
## ------------------------------------------------------------

sub cmd_pause {
	my $self = shift;

	# Set ntodo variable to 0
	$self->var('ntodo', 0);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_perl.pl
## ------------------------------------------------------------

sub cmd_perl {
	my $self = shift;
	my $cmd = shift;
	my $file = shift;
	my $verbose = shift;
	my $corpus = shift;

    my $time = - time();

	# Read command from file, if desired
	if ($file) {
		my @files = split(/ /, $cmd);
		$cmd = "";
		foreach my $f (@files) {
			if (-r $f) {
				open(FILE, "<$f")
					|| return error("cannot open script file for reading: $f");
				while (my $line = <FILE>) {
					$cmd .= $line;
				}
				close(FILE);
			}
		}
	}

	# Process current graph or all files in corpus
    my $iostatus = $|; $| = 1; my $c = 0;
	my $progress = "";
	my $corpusfiles = $corpus
		? $self->{'corpus'} 
		: [$self->graph()->id()];
	my $graph = $self->graph();
	foreach my $f (@$corpusfiles) {
        # Print progress report 
        if ($corpus && ! $self->quiet()) {
            print " \b\b" x length($progress);
            my $percent = int(100 * $c / (1 + $#{@$corpusfiles}));
            $progress = sprintf('Searched %02i%%. Elapsed: %s. ETA: %s. File: %s',
                $percent,
                seconds2hhmmss(time()+$time),
                seconds2hhmmss(int((100-$percent) 
                        / ($percent || 1) * (time()+$time))),
				$f);
            print $progress;
            ++$c;
        }

		# Load new file from corpus, if desired
		$self->cmd_load($graph, undef, $f) if ($corpus);
		$graph = $self->graph();

		# Prepend command with initializing code
		@perl_args = ($self, $graph, $self->lexicon());
		my $pcmd = 'my $L = pop(@perl_args); my $G = pop(@perl_args); '
				. 'my $I = pop(@perl_args); ' . $cmd;

		# Execute command
		my $value = eval($pcmd);

		# Print result of command and any errors
		$value = 'undef' if (! defined($value));
		my $str = ($verbose ? "return: $value\n" : "")
			. ($@ ? "errors: " . $@ : "");
		print $str . "\n"
			if (! $corpus && ! $self->quiet());

		# Abort if requested
		last() if ($self->abort());
	}
    print "\b" x length($progress);
	
	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_print.pl
## ------------------------------------------------------------

sub cmd_print {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $follow = shift;

	# Update follow or print file
	if ($follow) {
		$file = $graph->fpsfile() || $self->fpsfile();
	} else {
		$graph->psfile($file) if ($file);
		$file = $graph->psfile();
	}
	# print "printing $graph to $file\n" if (! $self->quiet());

	# Print file
	if ($file) {
		my $ps = $graph->postscript($self) || "\n";
		my $tmpfile = $file . ".utf8";
		my $tmpfile2 = $file . ".final";
		#open(PSFILE, ">:encoding(iso-8859-1)", $file . "~") 
		#open(PSFILE, ">:utf8", $tmpfile) 
		#print "Printing $tmpfile $tmpfile2 $file\n";
		open(PSFILE, ">", $tmpfile) 
			|| return error("cannot open file $file for printing!");
		print PSFILE $ps;
		close(PSFILE);
		my $iconv = $self->{'options'}{'iconv'} || 'cat';
		my $cmd = $iconv . " $tmpfile > $tmpfile2";
		system("cp $tmpfile $tmpfile2");
		system($cmd);
		system("cp $tmpfile2 $file");
		system("rm $tmpfile");
		system("rm $tmpfile2");
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_pstep.pl
## ------------------------------------------------------------

sub cmd_pstep {
	my $self = shift;
	my $graph = shift;
	my $step = shift;
	$step = "+1" if (! defined($step));

	# Set step in graph
	my $ostep = $graph->pstep() || 0;
	$graph->pstep($1) if ($step =~ /^([0-9]+)$/);
	$graph->pstep($ostep + $1) if ($step =~ /^\+([0-9]+)$/);
	$graph->pstep($ostep - $1) if ($step =~ /^-([0-9]+)$/);
	print "pstep=" . $graph->pstep() . "\n";

	# Update graph
	$self->cmd_return($graph);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_redirect.pl
## ------------------------------------------------------------

my $OLDSTDOUT;
my $NEWSTDOUT;

sub cmd_redirect {
	my $self = shift;
	my $file = shift;

	#!/usr/bin/perl
	
	if (defined($file)) {
		# Save old STDOUT
		if (! defined($OLDSTDOUT)) {
			open $OLDSTDOUT, ">&STDOUT" or die "Can't dup STDOUT: $!";
		}

		# Close old file STDOUT
		if (defined($NEWSTDOUT)) {
			close($NEWSTDOUT);
			$NEWSTDOUT = undef;
		}

		# Open new STDOUT
		print STDERR "Redirecting STDOUT to $file\n";
		open $NEWSTDOUT, '>', $file or die "Can't open new STDOUT: $!";
		open STDOUT, ">&", $NEWSTDOUT or die "Can't redirect STDOUT: $!";
		select STDOUT; $| = 1;    # make unbuffered
	} else {
		if ($OLDSTDOUT) {
			open STDOUT, ">&", $OLDSTDOUT or die "Can't dup \$oldout: $!";
			print "Redirecting to original STDOUT\n";
		}

		# Close old file STDOUT
		if (defined($NEWSTDOUT)) {
			close($NEWSTDOUT);
			$NEWSTDOUT = undef;
		}
	}

	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_relations.pl
## ------------------------------------------------------------

sub cmd_relations {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Hash containing all found relations
	my $relations = $self->{'relations'} = 
		{	'cframes' => {},
			'aframes' => {},
		};
	my $cframes = $relations->{'cframes'};

	# Recognizing edges
	my $edges = 
		{	'comp' => 
				sub {my $var = shift; 
					$var =~ /^\[?(.*obj|expl|possd|pred|subj|num.|part)\]?$/ },
			'agov' => 
				sub { my $var = shift; 
					$var =~ /^$/ },
		};

	# Look at each node in graph
	for (my $i = 0; $i < $graph->size(); ++$i) {
		# Skip current node if it is a comment
		my $head = $graph->node($i);
		next() if $head->comment();

		# Find head word and head category
		my $headW = $head->input();
		my $headC = $head->var('msd');

		# Find complement frame at node $i
		my $cframe = [['*', $headC, $headW, $i]];
		foreach my $edge (@{$head->out()}) {
			if (&{$edges->{'comp'}}($edge->type())) {
				my $rel = $edge->type();
				$rel =~ s/\[(.*)\]/$1/g;
				my $comp = $graph->node($edge->in());
				my $compW = $comp->input();
				my $compC = $comp->var('msd');
				
				# Insert complement in complement frame
				push @$cframe, [$rel, $compC, $compW, $edge->in()];

				# Insert complement in complements list
				$cframes->{"# $rel"} = [] if (! $cframes->{"# $rel"});
				push @{$cframes->{"# $rel"}}, 
					[	['#', $headC, $headW, $i], 
						[$rel, $compC, $compW, $edge->in()]];
			}
		}

		# Save complement frame
		my $framename = join(" ", 
			sort(map {my $a = $_->[0]; $a =~ s/\[(.*)\]/$1/g; $a} @$cframe));
		$cframes->{$framename} = [] 
			if (!  $cframes->{$framename});
		push @{$cframes->{$framename}}, $cframe;
	}

	# Save description in file /tmp/dtag-relations
	if ($file) {
		open(REL, ">$file") || 
			return error("cannot open file $file for writing relations");
		my @rel = sort(keys(%{$cframes}));
		foreach my $r (@rel) { 
			# Print relation header
			printf REL "%s=%s\n", 
				scalar(@{$cframes->{$r}}),
				$r;

			# Find relation entries, sorted by first two letters of
			# categories
			my $cats = {};
			foreach my $e (@{$cframes->{$r}}) {
				# Sort complements and find their category string
				my @comps = sort {$a->[0] cmp $b->[0]} @$e;
				my $cat = join(" ", map {($_->[0] || "") . ":" 
					. substr(($_->[1] || ""), 0, 2)} @comps);

				# Sort complements by category string
				$cats->{$cat} = [] if (! $cats->{$cat});
				push @{$cats->{$cat}}, [@comps];
			}

			# Print relation entries
			foreach my $cat (sort(keys(%$cats))) {
				printf REL "\t%s=$cat\n", scalar(@{$cats->{$cat}});
				foreach my $e (@{$cats->{$cat}}) {
					print REL "\t\t" . join(" ", 
						map {"[" . ($_->[2] || "") 
							. ":" . ($_->[1] || ""). "]"} @$e) . "\n";
				}
			}
		}
		close('REL');
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_relhelp.pl
## ------------------------------------------------------------

sub cmd_relhelp {
	my $self = shift;
	my $graph = shift;
	my $name = shift;
	my $printex = shift;

	# Find relation name
	my $relsetname = $graph->var("relset") || $self->var("relset");
	my $relset = $self->var("relsets")->{$relsetname} || undef;
	if (! defined($relset)) {
		error("Current graph has no associated relation set"
			. " (see relset command)");
		return 1;
	} 

	# Retrieve relation from relset
	my $relation = $relset->{$name};
	if (! defined($relation)) {
		error("Relation $name undefined in current relset!");
		return 0;
	}

	my ($sname, $lname, $iparents, $tparents,
			$ichildren, $sdescr, $ldescr, $ex, $deprecated,
			$lineno, $see, $connectives) 
		= map {$relation->[$_]} 
			($REL_SNAME, $REL_LNAME, $REL_IPARENTS, $REL_TPARENTS,
			$REL_ICHILDREN, $REL_SDESCR, $REL_LDESCR, $REL_EX,
			$REL_DEPRECATED, $REL_LINENO, $REL_SEE, $REL_CONN);
	
	# Print help information for relation
	print "\n$sname = $sdescr"
		. ($sname ne $lname ? " (long name: $lname)" : "") 
		. " [row $lineno]\n";
	print "\nDEFINITION: $ldescr\n" if (defined($ldescr));
	print "\nTYPICAL CONNECTIVES: $connectives\n" if ($connectives);
	if ($name ne $sname && $name ne $lname) {
		print "\nTHE RELATION $name IS DEPRECATED!\n";
	}

	print "\nSUPER TYPES:\n" .
		join("", map {countname($relset, $_)}
			sort(keys(%$iparents))) . "\n" if (defined($iparents) &&
			%$iparents);
	print "SUBTYPES:\n" .
		join("", map {countname($relset, $_)} 
			sort(keys(%$ichildren))) . "\n" if (defined($ichildren) &&
			%$ichildren);
	my $seealso = [split(/\s+/, $see || "")];
	print "SEE ALSO:\n" .
		join("", map {countname($relset, $_)} 
			@$seealso) . "\n" if (@$seealso);
	my $confusion = [@{$self->{'confusion'}{$relsetname}{$sname}}] || [0,0,0,0];
	my $confcount = shift(@$confusion);
	my $agreement = join("/", shift(@$confusion), shift(@$confusion),
		shift(@$confusion));
	print "CONFUSION ($confcount nodes, $agreement full/unlabeled/label agreement):\n    "
		. join(" ", @$confusion) . "\n";

	# Examples
	if (defined($ex)) {
		$ex = encode_utf8(decode_utf8($ex));
		# Print examples on screen
		print "\nEXAMPLES:\n" if ($printex);

		# Create example graph
		my $exlist = ["$ex"];
		$ex =~ s/([^\n])\n([^\n])/$1 $2/g;
		my @examples = split("\n+", $ex);
		print "\t" . join("\n\n\t", @examples) . "\n\n" if ($printex);
		push @$exlist, @examples;
		$self->cmd_example($graph, shift(@examples), 1);
		my $egraph = $self->graph();
		$egraph->var("example", $exlist);
		foreach my $example (@examples) {
			$self->cmd_example($egraph, "-add " . $example, 1);
		}

		# Create viewer for example graph if non-existent
		$egraph->mtime("");
		my $exfpsfile = $self->var("exfpsfile");
		if (! $exfpsfile) {
			# Creating new example viewer
			$self->do("viewer");
		} elsif (! `ps e -w | grep $exfpsfile | grep -v grep`) {
			# Reopening closed example viewer
			$self->do("viewer");
		} else {
			# Reusing example viewer
			my $exfpsfile = $self->var("exfpsfile");
			$egraph->fpsfile($exfpsfile);
		}
		$self->cmd_return($egraph);

		# Close example graph
		$self->var("examplegraph", $egraph);
		if ($egraph->var("example")) {
#			$self->cmd_save($egraph, undef, "/tmp/example.$$.tag");
			$self->cmd_close($egraph);
		}
	}

	# Return
	return 1;
}

sub countname {
	my $relset = shift;
	my $name = shift;
	my $count = $relset->{$name}->[$REL_TCHILDCNT];
	my $descr = $relset->{$name}->[$REL_SDESCR];
	$count = 0 if (! defined($count));
	$descr = "" if (! defined($descr));
	return "    $name = $descr" . ($count == 0 ? "" : " ($count)") .  "\n";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_relhelpsearch.pl
## ------------------------------------------------------------

sub cmd_relhelpsearch {
	my $self = shift;
	my $graph = shift;
	my $regex = shift;

	# Find relation name
	my $relsetname = $graph->var("relset") || $self->var("relset");
	my $relset = $self->var("relsets")->{$relsetname} || undef;
	if (! defined($relset)) {
		error("Current graph has no associated relation set"
			. " (see relset command)");
		return 1;
	} 

	# Find all relations where a field matches regex
	my $match = sub {
		my $s = shift;
		$s =~ /$regex/;
	};

	# Find matching relations
	my $matches = [];
	foreach my $relation (sort(keys(%$relset))) {
		my $list = $relset->{$relation};
		if (ref($list) eq "ARRAY" && $list->[$REL_SNAME] eq $relation) {
			my $s = join("	", map {defined($_) ? $_ : ""} @$list);
			push @$matches, $relation 
				if (&$match($s));
		}
	}

	# Print matches
	print "\nMATCHES:\n"
		. join("", map {countname($relset, $_)}
			@$matches) . "\n";

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_relset.pl
## ------------------------------------------------------------

use utf8;

sub cmd_relset {
	my $self = shift;
	my $graph = shift;
	my $name = shift;
	my $file = shift;

	# Print current relset if no file is given
	if (! defined($name)) {
		print "Current relset: " . $self->var("relset") . "\n";
		return 1;
	} 

	if (! defined($file)) {
		if (! exists $self->var("relsets")->{$name}) {
			print "Unknown relset: $name\n";
			return 1;
		}
		print "Current relset: " . $self->var("relset", $name) . "\n";
		$graph->var("relset", $name);
		return 1;
	}

	# Open csv file (replacing ~ with home dir)
	print "Loading relation set \"$name\" from $file\n";
	if ($file =~ /^https?:\/\//) {
		my $cmd = "wget -q -O /tmp/dtag.wget2 '$file'";
		print $cmd . "\n" if ($debug_relset);
		system($cmd);
		system("iconv -f utf8 -t utf8//TRANSLIT /tmp/dtag.wget2 > /tmp/dtag.wget");
		$file = "/tmp/dtag.wget";
	} else {
		$file =~ s/^~/$ENV{HOME}/g;
	}
	open("CSV", "<:encoding(utf8)", $file)
		|| return error("cannot open csv-file for reading: $file $!");
	#CORE::binmode("CSV", $self->binmode()) if ($self->binmode());
	
	# Create relations object
	my $relations = {"_name_" => $name, "_file_" => $file};
	
	# Read relations Text::CSV_XS;
	#require Text::CSV;
	require Text::CSV_XS;
	my $csv = Text::CSV_XS->new ({ 'binary' => 1 })
		or error("Cannot use CSV: " . Text::CSV_XS->error_diag());
	my $classes = [];

	# Skip first line
	$csv->getline("CSV");
	my $lineno = 1;
	my $errorclasses = {};
	while (my $row = $csv->getline("CSV")) {
		# Read line from relations CSV file
		++$lineno;

		$row = [map {decode_utf8($_)} @$row];

		# Read fields
		for (my $i = 0; $i < 15; ++$i) {
            $row->[$i] = "" if (! defined($row->[$i]));
        }
		my ($comment, $shortname, $longname, $deprecatednames, 
			$supertypes, $shortdescription, $longdescription, $seealso, 
			$examples, $connectives) = @$row;
		$longname = $shortname if ((! defined($longname)) || $longname =~ /^\s*$/);

		# Skip line if short name or long name are undefined
		next if (! (defined($shortname) && defined($longname)));

		# Create relation object
		my $relation = [$shortname, $longname, 
			undef, {}, {},
			$shortdescription, $longdescription, $examples,
			$deprecatednames, $supertypes, $lineno, 0, 0, $seealso,
			$connectives];
		
		# Add relation to relations table under its different names
		$errorclasses->{"\"" . $shortname . "\" (line " . $lineno . ")"} = 1
			if ($shortname ne "" && exists $relations->{$shortname});
		$errorclasses->{"\"" . $longname . "\" (line " . $lineno . ")"} = 1
			if ($longname ne "" && exists $relations->{$longname});
		push @$classes, $shortname, $longname;
		$relations->{$shortname} = $relation;
		$relations->{$longname} = $relation;
		map {
			$relations->{$_} = $relation
		 		if (! exists $relations->{$_});
			push @$classes, $_
		} split(/\s+/, $deprecatednames);
		if ($lineno < 10 && $debug_relset) {
			print $debug_relset "csv-relations: "
				. $relations->{$shortname}[7] . "\n";
		}
	}
	close(CSV);

	# Compile relation hierarchy
	foreach my $relation (@$classes) {
		add_relation_nodes($relations, $relation);
	}

	# Save relations
	$self->var("relsets")->{$name} = $relations;
	$self->var("relset", $name);
	$graph->var("relset", $name);

	# Print multiply defined classes
	print join("", map {"ERROR: class $_ already defined\n"}
		sort(keys(%$errorclasses)));

	# Return
	return 1;
}

# Return short name for relation
sub add_relation_nodes {
	my $relations = shift;
	my $relation = shift;
	my $nesting = shift || 0;

	# Do nothing if relation does not exist
	return undef if (! exists $relations->{$relation});

	# Find short name for type
	my $rellist = $relations->{$relation};
	
	# Return short name if parent types already defined
	my $name = $rellist->[$REL_SNAME];
	return $name if (defined($rellist->[$REL_IPARENTS]));

	# Find short names for immediate parents, making sure that they
	# have been added as relations first
	my $iparents = $rellist->[$REL_IPARENTS] = {};
	foreach my $parent (split(/\s+/, $rellist->[$REL_STYPES] || "")) {
		# Make sure that parent exists
		my $pshort = add_relation_nodes($relations, $parent, $nesting + 1);
		next if (! (defined($pshort) && $pshort ne ""));

		# Add parent to relation's iparents
		$rellist->[$REL_IPARENTS]{$pshort} = 1;

		# Add relation to parent's child relations
		my $plist = $relations->{$pshort};
		$plist->[$REL_ICHILDREN]->{$name} = 1;

		# Increment count for parent
		$relations->{$pshort}[$REL_CHILDCNT]++;

		# Add all parent's tparents to this relations' tparents
		my $tparents = $rellist->[$REL_TPARENTS];
		map {	$tparents->{$_} = 1; 
				$relations->{$_}[$REL_TCHILDCNT]++;
			} ($pshort, keys(%{$plist->[$REL_TPARENTS]}));
	}

	# Return short name
	return $name;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_relset2latex.pl
## ------------------------------------------------------------

my $relset_example_id = 0;
my $relset_undef = "\\relax";
my $relset_indent = "\\mytab";
my $relset_cmdsummary = "";
my $relset_example_prefix = "";

sub cmd_relset2latex {
	my $self = shift;
	my $graph = shift;
	my $filename = shift;
	my $relations = shift || "ANY";

	# Find relset
	my $relset = $graph->relset();
	if (! defined($relset)) {
		error("No relset for the current graph!");
		return 1;
	}
		
	# Provide default filename if missing
	my $relsetname = $graph->relsetname();
	if (! $filename) {
		$filename = "$relsetname-relations.tex";
	}

	# Set example filename
	$relset_example_prefix = "$filename";
	$relset_example_prefix =~ s/\.tex$//g;

	# Open file 
	$relset_example_id = 0;
	$relset_cmdsummary = "";
	print "printing relset to $filename\n";
	open(my $ofh, ">:encoding(UTF-8)", $filename);
	
	# Print call to overview
	my $ofile = "$filename";
	$ofile =~ s/.tex$//g;
	$ofile .= "-overview.tex";
	print $ofh "\n\n\t\\overviewfile{$ofile}\n\n";

	# Open confusion table
	my $confusion = $self->{'confusion'}{$relsetname};

	# Visit nodes depth-first
	my $visited = {};	
	my $tovisit = [];
	foreach my $relspec (split(/\s+/, $relations)) {
		# Find nodes to visit
		if ($relspec =~ /^([^-]+)-?.*$/) {
			push @$tovisit, $1;
		} else {
			# Find all short names in the relset
			my $snames = {};
			map {$snames->{$_->[0]} = 1 if (ref($_) eq "ARRAY")} 
				values(%$relset); 
			$tovisit = [
				sort {scalar(keys(%{$relset->{$a}[3]}))
					<=> scalar(keys(%{$relset->{$b}[3]}))}
						keys(%$snames)];
		}

		# Compile $relspec
		my $type = $self->query_parser()->Type(\$relspec);
		if (! $type) { 
			error("Cannot parse type specification $relspec"); 
			return 1;
		}
		
		# Iterate over all relations
		foreach my $relation (@$tovisit) {
			$self->relset2latex_visit($graph, $ofh, $relset, $confusion, $relation, $type, $visited, "");
		}
	}

	# Close file
	close($ofh);

	# Print overview
	open(my $ovfh, ">:encoding(UTF-8)", $ofile);
	print $ovfh "\\begin{overview}{$relations}\n\n$relset_cmdsummary\\end{overview}\n";
	close($ovfh);
}

sub relset2latex_visit {
	my $self = shift;
	my $graph = shift;
	my $ofh = shift;
	my $relset = shift;
	my $confusion = shift;
	my $relname = shift;
	my $type = shift;
	my $visited = shift;
	my $indent = shift;

	# Do not revisit already visited relations
	return if ($visited->{$relname});
	$visited->{$relname} = 1;

	# Do not visit relations with blank names
	return if ($relname =~ /^\s*$/);

	# Only process relations that match $type
	return if (! $type->match($graph, $relname, $relset));
	#print $relname . "\n";

	# Retrieve relation data
	my $relation = $relset->{$relname};
	return if (! $relation);
	my ($sname, $lname, $iparents, $tparents, $ichildren, $sdescr, 
		$ldescr, $ex, $deprecated, $lineno, $see, $connectives) 
			= map {$relation->[$_]} ($REL_SNAME, $REL_LNAME,
				$REL_IPARENTS, $REL_TPARENTS, $REL_ICHILDREN, $REL_SDESCR,
				$REL_LDESCR, $REL_EX, $REL_DEPRECATED, $REL_LINENO, $REL_SEE,
				$REL_CONN);
																			   
	# Print examples
	my @examples = ();
	foreach my $example (split(/\n+/, $ex)) {
		my $exfile = $relset_example_prefix 
			. sprintf("-%04d", ++$relset_example_id);
		open(EXAMPLE, ">:encoding(UTF-8)", "$exfile.dtag");
		print EXAMPLE "example -nopos $example\n";
		close(EXAMPLE);
		push @examples, "$exfile.pdf";
	}

	# Print relation
	print $ofh "\\begin{relation}\n";
	print $ofh "	\\relname{" . texreldef($sname, $relset) . "}{";
	print $ofh "\\isa{" . join(" ", map {texrelref($_, $relset)}
			sorted_relations($relset, keys(%$iparents))) . "}"
		if (%$iparents);
	print $ofh "}{\\lineno{$lineno}}%\n";
	my @sdescrx = ();
	push @sdescrx, "\\xlong{" . texrel($lname) . "}"
		if ($lname ne "" && $lname ne $sname);
	push @sdescrx, "\\deprecated{" . texrel($deprecated) . "}"
		if ($deprecated ne "");
	my $texsdescr = tex(ucfirst($sdescr));
	if (@sdescrx) {
		print $ofh "	\\sdescrx{$texsdescr}{" 
			. join(", ", @sdescrx) . "}%\n";
	} else {
		print $ofh "	\\sdescr{$texsdescr}%\n";
	}
	print $ofh "	\\begin{ldescription}\n\t\t"
		. tex(ucfirst($ldescr)) . "\n\\end{ldescription}\n" if ($ldescr);
	print $ofh "	\\connectives{$connectives}%\n"
		if ($connectives);
	print $ofh "	\\tparents{" .  join(" ", map {texrelref($_, $relset) 
			. "%\n"} 
		sorted_relations($relset, grep {! $iparents->{$_}} keys(%$tparents)))
			. "}\n" if (%$tparents);
	print $ofh "	\\subtypes{" . join(" ", map {texrelref($_, $relset)} 
			sorted_relations($relset, keys(%$ichildren))) . "}%\n" 
		if (%$ichildren);
	print $ofh "	\\related{" . join(" ", map {texrelref($_, $relset)} 
		sorted_relations($relset, split(/\s+/, $see))) . "}%\n" if ($see);
	my $confuse = [@{$confusion->{$sname} || []}];
	if (@$confuse) {
		print $ofh "	\\confusions{" . shift(@$confuse) . "}{";
		foreach my $c (@$confuse) {
			$c =~ /^([0-9]+)\%=(.*)$/;
			print $ofh "\\confuse{$1}{" . texrelref($2, $relset) . "}" 
				if (defined($1) && defined($2));
		}
		print $ofh "}\n";
	}
	$relset_cmdsummary .= "	\\cmdsummary{$indent}{" . texrelref($sname, $relset) . "}{"
		. tex($sdescr) . "}%\n";
	print $ofh "	\\begin{examples}\n"
		. join("", map {"\t\t\\exfig{$_}\n"} @examples)
		. "\t\\end{examples}\n" if (@examples);
	print $ofh "\\end{relation}\n\n";

	# Visit child relations in original order
	foreach my $subrel (sorted_relations($relset, keys(%$ichildren))) {
		$self->relset2latex_visit($graph, $ofh, $relset, $confusion, $subrel, $type, $visited,
		$indent . $relset_indent);
	}
}

sub texrel {
	my $rel = shift;
	$rel =~ s/\s+//g;
	my $texcmd = shift || "\\rel";
	return tex($rel) if ($rel eq "");
	return $texcmd . "{" . tex($rel) . "}";
}

sub texrelref {
	my $rel = shift;
	my $relset = shift;
	my $texcmd = shift || "\\relref";
	return tex($rel) if ($rel eq "" || $rel eq "\\relax");
	my $relation = $relset->{$rel};
	my $lineno = $relation ? $relation->[$REL_LINENO] : undef;
	return defined($lineno) 
		? texrel($rel, $texcmd ."{rel" . $lineno . "}") 
		: texrel($rel);
} 

sub texreldef {
	return texrelref(shift, shift, "\\reldef");
}

sub tex {
	my $s = shift;
	$s =~ s/\$/\\\$/g;
	$s =~ s/{/\\{/g;
	$s =~ s/}/\\}/g;
	$s =~ s/#/\\#/g;
	$s =~ s/&/\\&/g;
	$s =~ s/~/\\~/g;
	$s =~ s/%/\\%/g;
	return (length($s) != 0) ? $s : $relset_undef;
}

sub sorted_relations {
	my $relset = shift;
	my @relations = @_;
	return sort(@relations);
	#return sort {relation_lineno($relset, $a) <=> relation_lineno($relset, $b)} 
	#	@relations;
}

sub relation_lineno {
	my $relset = shift;
	my $relname = shift;
	my $relation = $relset->{$relname};
	return 1e20 if (! $relation);
	return $relation->[$REL_LINENO];
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_replace.pl
## ------------------------------------------------------------

sub cmd_replace {
	my ($self, $graph, $replace) = @_;

	# Replace at current position if replacement is given
	my $filelist = $self->{'replace_files'};
	my $matchlist = $self->{'replace_matches'};
	my $file = $filelist->[0];
	my $match = $matchlist->[0];
	my $relhash = $self->{'replace_hash'};

	# Check arguments
	if (! defined($filelist)) {
		error("autoreplace not active");
		return 1;
	}

	if ($replace) {
		if ($file && defined($match) && $graph &&
				($graph->file() || "") eq $file || $file =~ /^\[/) {
			# Find matching edge
			my $dep = $match->{'$dep'};
			my $gov = $match->{'$gov'};
			my $depnode = $graph->node($dep);
			my @edges = grep {$_->out() == $gov && $relhash->{$_->type()}} 
				@{$depnode->in()};
			my $edge = $edges[0];

			# Delete edge
			$graph->edge_del($edge) if ($edge);

			# Add new edge
			$self->cmd_edge($graph, $dep - $graph->offset(),
				$replace, $gov - $graph->offset());
			print "edit: $dep " . $replace . " $gov\n";
		}
	}

	# Advance to next position and show graph
	shift(@$matchlist);
	if (! @$matchlist) {
		# Save previous file
		if ($file && ($graph->file() || "") eq $file) {
			$self->cmd_save($graph);
		}

		# Advance to next graph and return if undefined
		shift(@$filelist);
		$file = $filelist->[0];
		if (! $file) {
			warning("replace: no more matches\n");
		    $self->{'replace_files'} = undef;
			my $gfile = $graph->file() || "";
			return 1;
		}
		$matchlist = $self->{'replace_matches'} 
			= [@{$self->{'matches'}{$file}}];
		# Load new graph
		if (! ($graph && ($graph->file() || "") eq $file)) {
	        $self->cmd_load($graph, undef, $file);
	        $graph = $self->graph();
			print "=== $file ===\n";
	    }
	}

	# Load first match
	$match = $matchlist->[0];
	$self->{'replace_match'} = {$graph => [$match]};
	my $dep = $match->{'$dep'};
	my $gov = $match->{'$gov'};
	my $min = min($dep, $gov);
	my $depnode = $graph->node($dep);
	my @edges = grep {$_->out() == $gov && $relhash->{$_->type()}} 
		@{$depnode->in()};
	my $edge = $edges[0];

	# Goto this position
	$self->cmd_show($graph, $min - $self->var('goto_context'));
	print "next: $dep " . $edge->type() . " $gov\n";

	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_resume.pl
## ------------------------------------------------------------

sub cmd_resume {
	my $self = shift;
	my $graph = shift;
	my $ntodo = shift;
	my $history = shift;

	# Set number of commands to perform
	my $todo = $self->var('todo');
	$self->var('ntodo', $ntodo || -1);
	
	# Read todo-list line by line, and perform do
	while ($self->var('ntodo') && @$todo) {
		# Perform line
		my $line = shift(@$todo);
		$self->var('ntodo', $self->var('ntodo') - 1)
			if (! ($line =~ /^\s*#.*$/));
		print "> $line" if (! ($self->quiet() || $line =~ /\\\s*/ || $line =~ /^\s*echo\s+/));
		$self->do($line, $history);

		# Abort if requested
		$self->var('ntodo', 0) if ($self->abort());
	}
	if (! $self->var("noupdate")) {
		$self->cmd_return() 
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_return.pl
## ------------------------------------------------------------

sub cmd_return {
	my $self = shift;
	my $graph = shift || $self->graph();

	# Do nothing if "noview" is set
	return 1 if ($self->var("noview"));

	# Send update command to graph
	$graph->update();

	# Print follow file
	$self->cmd_print($graph, undef, 1)
		if ($self->{'viewer'});
	if ($graph->var("gedit")) {
		my $lineno = $graph->var('imid') || 0;
		$self->cmd_gedit($graph, $lineno);
	}
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save.pl
## ------------------------------------------------------------

sub cmd_save {
	my $self = shift;
	my $graph = shift;
	my $ftype = shift || "";
	my $fname = shift || "";
	$fname =~ s/~/$ENV{HOME}/g;
	$ftype =~ s/^\s+//g;

    # Find type of file (-tag): look at ending, select .tag
	if (! $ftype) {
		# Default
		$ftype = (UNIVERSAL::isa($graph, 'DTAG::Alignment')) 
			? '-atag' : '-tag';

		# Other
		$ftype = '-tag' if ($fname =~ /\.tag$/);
		$ftype = '-atag' if ($fname =~ /\.atag$/);
		$ftype = '-alex' if ($fname =~ /\.alex$/);
		$ftype = '-tiger' if ($fname =~ /\.xml$/);
		$ftype = '-malt' if ($fname =~ /\.malt$/);
		$ftype = '-match' if ($fname =~ /\.match$/);
		$ftype = '-conll' if ($fname =~ /\.conll$/);
		$ftype = '-osdt' if ($fname =~ /\.osdt$/);
		$ftype = '-table' if ($fname =~ /\.table$/);
	}

	# Save file
	if ($ftype eq '-tag') {
		$self->cmd_save_tag($graph, $fname);
	} elsif ($ftype eq '-atag') {
		$self->cmd_save_atag($graph, $fname);
	} elsif ($ftype eq '-alex') {
		$self->cmd_save_alex($graph, $fname);
	} elsif ($ftype eq '-tiger') {
		$self->cmd_save_tiger($graph, $fname);
	} elsif ($ftype eq '-malt') {
		$self->cmd_save_malt($graph, $fname);
	} elsif ($ftype eq '-conll') {
		$self->cmd_save_conll($graph, $fname);
	} elsif ($ftype eq '-match') {
		$self->cmd_save_matches($fname);
	} elsif ($ftype eq '-osdt') {
		$self->cmd_save_osdt($graph, $fname);
	} elsif ($ftype eq '-table') {
		$self->cmd_save_table($graph, $fname);
	}

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save_alex.pl
## ------------------------------------------------------------

sub cmd_save_alex {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Check that graph is an alignment
	if (! UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		error("no active alignment");
		return undef;
	}

	# Check that alignment has an alexicon
	if (! $graph->alexicon()) {
		error("no active alignment lexicon");
		return undef;
	}

	# Find lexicon and update file name
	my $alexicon = $graph->alexicon();
	$alexicon->file($file) if ($file);
	$file = $alexicon->file();

	# Open tag file
	open("ALEX", "> $file") 
		|| return error("cannot open alex-file for writing: $file");

	# Print XML file
	print ALEX
		$alexicon->write_alex();

	# Close file
	close("ALEX");
	print "saved alex-file $file\n" if (! $self->quiet());

	# Mark alexicon as being unmodified
	$alexicon->mtime(undef);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save_atag.pl
## ------------------------------------------------------------

sub cmd_save_atag {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Update tag file name
	$graph->file($file) if ($file);
	$file = $graph->file();

	# Open tag file
	open("XML", "> $file") 
		|| return error("cannot open atag-file for writing: $file");

	# Print XML file
	print XML
		$graph->write_atag();

	# Close file
	close("XML");
	print "saved atag-file $file\n" if (! $self->quiet());

	# Mark graph as being unmodified
	$graph->mtime(undef);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save_conll.pl
## ------------------------------------------------------------

sub cmd_save_conll {
	my $self = shift;
	my $graph = shift;
	my $file = shift;
	my $filterstring = "isa(SYN+PRIM)";

	# Edge filter
	my $edge_filter = $self->edge_filter("$filterstring");
	my $pos = $graph->layout($self, 'pos') || sub {return 0};
	my $edgefiltersub = sub { 
		return defined($edge_filter) && defined($_) 
			? $edge_filter->match($graph, $_->type())
			: ! &$pos($graph, $_); 
		};
		
	# Calculate line numbers
	my $lines = [];
	my $line = 0;
	my $rightboundary = 0;
	my $boundaries = {};
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		my $input = $node->input();
		if (! $node->comment()) {
			$lines->[$i] = ++$line;

            # Update right boundary
            foreach my $e (grep {&$edgefiltersub($_)} @{$node->in()}) {
                my $n = $e->out();
                $rightboundary = $n if ($n > $rightboundary);
            }
            foreach my $e (grep {&$edgefiltersub($_)} @{$node->out()}) {
                my $n = $e->in();
                $rightboundary = $n if ($n > $rightboundary);
            }
		} 
		
		if ($rightboundary <= $i) {
			$line = 0;
			$boundaries->{$i} = 1;
		}
	}

	# Open CONLL file
	open("CONLL", "> $file") 
		|| return error("cannot open file for writing: $file");

	# Select variable for POSTAG/CPOSTAG
	my $tag = $self->option('conll_postag') || "tag";
	my $ctag = $self->option('conll_cpostag') || "tag";

	# Write CONLL file line by line
	my $prevblank = 1;
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);

		# Process non-comment nodes
		my $input = $node->input() || "??";
		if (! $node->comment()) {
			# ID
			my $ID = $node->var('id');
			$ID = $lines->[$i] if (! defined($ID));

			# FORM
			my $FORM = $input;
			$FORM =~ s/\s+//g;
			$FORM =~ s/&amp;/\&/g;

			# LEMMA
			my $LEMMA = $node->var('lemma') || "_";

			# CPOSTAG and POSTAG
			my $msd = $node->var($tag) || "??";
			my $POSTAG = $node->var($tag) || "??";
			my $CPOSTAG = $node->var($ctag) || "??";
			my $FEATS = "";

			# Special Parole tag filtering
			if ($tag eq "msd") {
				my $msd = my $XPOSTAG = $POSTAG = $CPOSTAG = $node->var($tag);

				# Compute cpostag
				$XPOSTAG =~ s/^(.).*/$1/g;
				$XPOSTAG = "SP" if ($XPOSTAG eq "S");
				$XPOSTAG = "RG" if ($XPOSTAG eq "R");

				# Compute postag
				$CPOSTAG =~ s/^(..).*$/$1/;
				$CPOSTAG = "I" if ($CPOSTAG =~ /^I/);
				$CPOSTAG = "U" if ($CPOSTAG =~ /^U/);

				# FEATS
				$FEATS = conll_msd2features($XPOSTAG, 
					substr($msd, min(length($msd), 2)));
				$FEATS = ($FEATS =~ /^_$/) ? "" : "$FEATS";
			}
			$FEATS = ($FEATS ne "" ? "$FEATS|" : "") . "id=$ID"; 

			# HEAD AND DEPREL
			my $edges = [grep {&$edgefiltersub($_)} @{$node->in()}];
			my ($head, $type) = (0, "ROOT");
			if (scalar(@$edges) >= 1) {
				# More than one primary parent
				if (scalar(@$edges) > 1) {
					# Try to filter out edges ending in '#' -- in the
					# Copenhagen Danish-English treebank, these may
					# indicate dependencies into non-root morphemes
					$edges = [grep {my $s = $_->type(); $s !~ /#$/} @$edges];

					# Check again
					if (scalar(@$edges) > 1) {
						warning("node $i: more than one primary head");
					} else {
						warning("node $i: more than one primary head, but resolved problem by ignoring relations ending with '#'");
					}
				}

				# One primary parent 
				my $edge = $edges->[0];
				$type = $edge->type() || "??";
				$head = $lines->[$edge->out()] || "??";
			}
			my ($HEAD, $DEPREL) = ($head, $type);
			$HEAD = "0" if ($head eq "??");

			# PHEAD and PDEPREL
			my ($PHEAD, $PDEPREL) = ("_", "_");

			# Print head and type
			printf CONLL "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
				$lines->[$i], $FORM,
				($LEMMA || "_"),
				($CPOSTAG || "_"), ($POSTAG || "_"), ($FEATS || "_"),
				($HEAD || "0"), ($DEPREL || "_"), $PHEAD, $PDEPREL;
			$prevblank = 0;
		} 

		if ($boundaries->{$i} && $prevblank == 0) {
			print CONLL "\n";
			$prevblank = 1;
		}
	}

	# Close file
	close("CONLL");
	print "saved conll-file $file\n" if (! $self->quiet());

	# Return
	return 1;
}

sub conll_msd2features {
	my ($CPOSTAG, $featstr) = @_;
	my @featlist = ();
	my $position = 3;
	my $feat = '';

	# Interpret feature string $s
	while ($featstr) {
		# Extract feature string
		if ($featstr =~ /^\[/) {
			my $i = index($featstr, ']');
			$feat = substr($featstr, 1, $i);
			$featstr = substr($featstr, $i+1);
		} else {
			$feat = substr($featstr, 0, 1);
			$featstr = substr($featstr, 1);
		}

		# '=' means that feature is in general not defined for this
		# coarse pos; '-' means that it not defined for this
		# particular fine pos

		if ($feat !~ /[-=]/) {
			my $featname = $conll_msd2features_table->{$CPOSTAG}[$position - 3][0];
			my @values = ();
			for (my $i = 0; $i < length($feat); ++$i) {
				my $value = $conll_msd2features_table
						->{$CPOSTAG}[$position-3][1]{substr($feat, $i, 1)};
				push @values, $value
					if ($value);
			}
			my $featval = join("/", @values);
			push @featlist, "$featname=$featval"
				if ($featname);
		}	
		++$position;
	}

	return join("|", @featlist) || "_";	
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save_malt.pl
## ------------------------------------------------------------

sub cmd_save_malt {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Calculate line numbers
	my $lines = [];
	my $line = 0;
	my $rightboundaries = {};
	my $rightboundary = 0;
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		my $input = $node->input();


		# Process node
		if (! $node->comment()) {
			$lines->[$i] = ++$line;

			# Update right boundary
			foreach my $e (@{$node->in()}) {
				my $n = $e->out();
				$rightboundary = $n if ($n > $rightboundary);
			}
			foreach my $e (@{$node->out()}) {
				my $n = $e->in();
				$rightboundary = $n if ($n > $rightboundary);
			}
		}
		
		print "i=$i rb=$rightboundary\n";
		# Check for boundary
		if ($input =~ /^<\/s>/ || $rightboundary <= $i) {
			print "\n";
			$line = 0;
			$rightboundaries->{$i} = 1;
		}
	}

	# Open MALT file
	open("MALT", "> $file") 
		|| return error("cannot open tag-file for writing: $file");

	# Write MALT file line by line
	my $pos = $graph->layout($self, 'pos') || sub {return 0};
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);

		# Process non-comment nodes
		my $input = $node->input() || "??";
		if (! $node->comment()) {
			my $tag = $node->var($self->var('malt_feature_tag') || "msd") 
				|| "??";

			# Find first top dependency edge
			my $edges = [grep {! &$pos($graph, $_)} @{$node->in()}];
			my ($head, $type) = (0, "HEAD");
			if (scalar(@$edges) >= 1) {
				# One primary parent 
				my $edge = $edges->[0];
				$type = $edge->type() || "??";
				$head = $lines->[$edge->out()] || "??";

				# More than one primary parent
				if (scalar(@$edges) > 1) {
					warning("node $i: more than one primary head");
				}
			}

			# Print head and type
			print MALT "$input\t$tag\t$head\t$type\n";
		} 
		
		if ($rightboundaries->{$i}) {
			print MALT "\n";
		}
	}

	# Close file
	close("MALT");
	print "saved malt-file $file\n" if (! $self->quiet());

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save_matches.pl
## ------------------------------------------------------------

sub cmd_save_matches {
	my $self = shift;
	my $file = shift;

	# Open tag file
	open("MATCH", "> $file") 
		|| return error("cannot open match-file for writing: $file");

	# Find keys
	my $matches = $self->{'matches'};
	my $keyhash = {};
	my $varkeys = {};
	foreach my $file (keys(%$matches)) {
		foreach my $match (@{$matches->{$file}}) {
			map {$keyhash->{$_} = 1 if ($_ =~ /^\$/)} keys(%$match);
			map {
				if ($_ =~ /^\$/) {
					my $k = $match->{'vars'}{$_};
					$k = "" if (! defined($k));
					my $k0 = $varkeys->{$_};
					$k0 = $k if (! defined($k));
					warning("Key mismatch for key $_: $k vs. $k0")
						if ($k ne $k0);
					$varkeys->{$_} = $k;
				}
			} keys(%$match);
		}
	}
	my @keylist = sort(keys(%$keyhash));

	# Write MATCH file
	print MATCH "\"file\"\t\"" 
		. join("\"\t\"", map {
			my $k = $varkeys->{$_}; 
			$_ . ($k ne "" ? "@" . $k : "")} @keylist) . "\"\n";
	foreach my $file (sort(keys(%$matches))) {
		my $mgraph = $self->graph($self->gid2index($file));
		my $filename = ($mgraph && $mgraph->file()) ? 
			$mgraph->file() : $file;
		#print "mgraph=$mgraph filename=$filename\n";
		foreach my $match (@{$matches->{$file}}) {
			my $varkeys = $match->{'vars'} || {};
			print MATCH "\"$filename\"\t\""
				. join("\"\t\"",
					map {my $m = $match->{$_}; defined($m) ? $m : ""} @keylist) . "\"\n";
		}
	}

	# Close file
	close("MATCH");
	print "saved match-file $file\n" if (! $self->quiet());

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save_osdt.pl
## ------------------------------------------------------------

sub cmd_save_osdt {
	my $self = shift;
	my $graph = shift;
	my $file = shift || "";

	# Update tag file name
	$graph->file($file) if ($file);
	$file = $graph->file();

	# Check whether file name exists
    if (! $file) {
		error("cannot save: no name specified for file")
			if ($graph->mtime());
		return 1;
	}
						
	# Open tag file
	Node->use_color(0);
	open(XML, "> $file") 
		|| return error("cannot open osdt-file for writing: $file");
	print XML $graph->print_osdt();
	close(XML);
	print "saved osdt-file $file\n" if (! $self->quiet());

	# Mark graph as being unmodified
	$graph->mtime(undef);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save_table.pl
## ------------------------------------------------------------

sub cmd_save_table {
	my $self = shift;
	my $ograph = shift;
	my $file = shift || "";

	# Check whether table file name exists
    if (! $file) {
		error("cannot save: no name specified for table file");
		return 1;
	}

	# Create list of graph files to put into the table
	my @files = @_;
	@files = (undef) 
		if (! @files);

	# Global attributes
	my ($nodeattributes, $edgeattributes) = (["id"], ["in", "out"]);
	push @$nodeattributes, "file", "line";
	my $globalvars = {};

	# Process files
	my ($nodes, $edges, $nodecount) = ("", "", 1);
	foreach my $gfile (@files) {
		# Load graph for file
		my $graph;
		if (defined($gfile)) {
			# Load file
			$self->cmd_load($self->graph(), undef, $gfile);
			$graph = $self->graph();
			if (! defined($graph)) {
				error("Could not find graph file " . $gfile);
				next();
			}
		} else {
			# Undefined name: use old graph
			$graph = $ograph;
		}

		# Set file name
		$globalvars->{"node:file"} = $graph->file();

		# Create graph tables
		my ($nacount, $eacount) = (scalar(@$nodeattributes), scalar(@$edgeattributes));
		my ($gnodes, $gedges, $gnodecount) 
			= $graph->print_tables($nodecount, $nodeattributes, $edgeattributes, $globalvars);

		# Update tables
        $nodes = DTAG::Alignment::add_na_columns($nodes, scalar(@$nodeattributes) - $nacount);
		$edges = DTAG::Alignment::add_na_columns($edges, scalar(@$edgeattributes) - $eacount);
		$nodes .= $gnodes;
		$edges .= $gedges;
		$nodecount = $gnodecount;
		print $gfile . ": " . $nodecount . "\n";
	}

	# Add headers
	$nodes = "\"" . join("\"\t\"", @$nodeattributes) . "\"\n" . $nodes;
	$edges = "\"" . join("\"\t\"", @$edgeattributes) . "\"\n" . $edges;
							 
	# Open tag file
	open(XML, "> $file.nodes") 
		|| return error("cannot open table file for writing: $file.nodes");
	print XML $nodes;
	close(XML);
	open(XML, "> $file.edges") 
		|| return error("cannot open table file for writing: $file.edges");
	print XML $edges;
	close(XML);

	print "saved table files $file.nodes and $file.edges\n" 
		if (! $self->quiet());

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save_tag.pl
## ------------------------------------------------------------



sub cmd_save_tag {
	my $self = shift;
	my $graph = shift;
	my $file = shift || "";

	# Update tag file name
	$graph->file($file) if ($file);
	$file = $graph->file();

	# Check whether file name exists
    if (! $file) {
		error("cannot save: no name specified for file")
			if ($graph->mtime());
		return 1;
	}
						
	# Open tag file
	Node->use_color(0);
	open(XML, "> $file") 
		|| return error("cannot open tag-file for writing: $file");
	print XML $graph->print_tag();
	close(XML);
	print "saved tag-file $file\n" if (! $self->quiet());

	# Mark graph as being unmodified
	$graph->mtime(undef);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save_tiger.pl
## ------------------------------------------------------------

sub cmd_save_tiger {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Open file and XML writer
	my $encoding = $graph->encoding() || "UTF-8";
	my $output = IO::File->new($file, ">:encoding($encoding)")
		|| return error("cannot open TIGER XML file for writing: $file");
	my $writer = new XML::Writer('OUTPUT' => $output, 'DATA_MODE' => 1,
		'DATA_INDENT' => 2, 'UNSAFE' => 1);

	# Compute corpus name and date
	my $corpus = $file; $corpus =~ s/\.xml//;
	my $date = `date`; chomp($date);

	# Write XML header
	$writer->xmlDecl($encoding);

	# Write XML file 
	$writer->startTag("corpus", "id" => $corpus);

	# Header
	$writer->startTag("head");
		# Meta information
		$writer->startTag("meta");
			$writer->dataElement("name", $corpus);
			$writer->dataElement("date", $date);
			$writer->dataElement("author", "");
			$writer->dataElement("description", "");
			$writer->dataElement("format", "");
			$writer->dataElement("history", "");
		$writer->endTag("meta");

		# Start feature description
		$writer->startTag("annotation");
		$writer->emptyTag("feature", "name" => "word", "domain" => "FREC");

		# Information about features
		my $labels = $graph->labels($self, 500);
		my $vars = $labels->{'_vars'};
		foreach my $f (@$vars) {
			# Describe feature
			$writer->startTag("feature", , "name" => $f, 
					"domain" => "FREC");
				# Describe feature values
				foreach my $v (@{$labels->{$f} || []}) {
					$writer->dataElement("value", "", "name" => 
						(defined($v) && $v ne "") ? $v : "--");
				}
			$writer->endTag("feature");
		}

		# Information about primary edge labels
		$writer->startTag("edgelabel");
		foreach my $e ("--", @{$labels->{'_edges1'}}) {
			$writer->dataElement("value", "", "name" => $e);
		}
		$writer->endTag("edgelabel");

		# Information about secondary edge labels
		$writer->startTag("secedgelabel");
		foreach my $e (@{$labels->{'_edges2'}}) {
			$writer->dataElement("value", "", "name" => $e);
		}
		$writer->endTag("secedgelabel");

		# End feature description
		$writer->endTag("annotation");

	# End header
	$writer->endTag("head");

	# Create secondary edge hash
	my $secondary = {};
	map {$secondary->{$_} = 1} @{$labels->{'_edges2'}};

	# Begin body and process graph
	$writer->startTag("body");
	my $size = $graph->size();
	my $s = 0;
	for (my $first = 0; $first < $size; ++$first) {	
		my $last = $first;
		my $root = $first;
		if ($self->var('tag_segment_ends')) {
			# Method 1: Use existing <s> and </s> marks
			for ( ; $last < $size; ++$last) {
				my $node = $graph->node($last);
				$root = $last if ($node && ! $node->comment());
				last() if ($node->comment() && 
					&{$self->var('tag_segment_ends')}($node->input()));
			}
		} else {
			# Method 2: Find first primary root at or after $first,
			# ie, the first node all of whose incoming edges are
			# secondary, and exit if no root was found.
			$root = $first;
			for (; $root < $size; ++$root) {
				#  Exit if root node isn't a real node
				my $rootnode = $graph->node($root);
				next() if (! $rootnode || $rootnode->comment());

				# Exit if root node has no primary edges
				my $primary = 0;
				foreach my $e (@{$rootnode->in()}) {
					# Primary edge exists if it isn't secondary
					$primary = 1 if (! secondary($secondary, $e->type()));
				}
				last() if (! $primary);
			}
			last() if ($root >= $size);

			# Find yield of first root, and find first and last node in yield
			my $yields = $graph->yields({}, $root)->{$root};
			$first = $yields->[0][0];
			$last = $yields->[scalar(@$yields)-1][1];
			print "root=$root span=$first-$last\n";
		}

		# Output sentence and graph
		++$s;
		$writer->startTag("s", "id" => "s$s");
		$writer->startTag("graph", "root" => "p${s}_$root");

		# Output terminals in yield
		$writer->startTag("terminals");
		for (my $id = $first; $id <= $last; ++$id) {
			# Retrieve node and skip if non-existent or comment
			my $node = $graph->node($id);
			next() if (! $node || $node->comment());

			# Construct hash with feature-value pairs
			my $fvpairs = {};
			map {	my $str = $graph->reformat($self, $_, $node->var($_)); 
					$str = "--" if (! defined($str) || $str eq "");
					$fvpairs->{$_} = $str
				} @$vars;

			# Write terminal tag for node
			$writer->emptyTag("t", "id" => "w${s}_$id", 
				"word" => $node->input(), %$fvpairs);
		}
		$writer->endTag("terminals");

		# Output non-terminals in yield
		$writer->startTag("nonterminals");
		for (my $id = $first; $id <= $last; ++$id) {
			# Retrieve node and skip if not in yield
			my $node = $graph->node($id);
			next() if (! $node || $node->comment());

			# Construct hash with feature-value pairs
			my $fvpairs = {};
			map {	my $str = $graph->reformat($self, $_, $node->var($_)); 
					$str = "--" if (! defined($str) || $str eq "");
					$fvpairs->{$_} = $str
				} @$vars;

			# Write non-terminal tag for node
			$writer->startTag("nt", "id" => "p${s}_$id", 
				"word" => $node->input(), %$fvpairs);

			# Write head edge
			$writer->emptyTag("edge", "idref" => "w${s}_$id",
				"label" => "--");

			# Write other outgoing edges within yield
			foreach my $e (@{$node->out()}) {
				# Check that edge is within yield
				my $idref = $e->in();

				# Write edge
				if (secondary($secondary, $e->type())) {
					# Secondary edge
					$writer->emptyTag("secedge", "idref" => "p${s}_$idref", 
						"label" => $e->type());
				} else {
					# Primary edge
					$writer->emptyTag("edge", "idref" => "p${s}_$idref", 
						"label" => $e->type());
				}
			}

			# Close non-terminal tag
			$writer->endTag("nt");
		}

		# End terminals, graph, and s
		$writer->endTag("nonterminals");
		$writer->endTag("graph");
		$writer->endTag("s");

		# Set $first to $last
		$first = $last;
	}

	# End body and corpus
	$writer->endTag("body");
	$writer->endTag("corpus");
	
	# Close writer and file
	$writer->end();
	$output->close();
	print "exported graph to TIGER-XML in file $file\n" if (! $self->quiet());

	# Return
	return 1;
}

sub secondary {
	my $secondary = shift;
	my $type = shift;

	# Check whether edge is secondary
	my $sec = 0;
	foreach my $s (keys(%$secondary)) {
		$sec = 1 if ($s eq $type);
	}

	# Return
	return $sec;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_script.pl
## ------------------------------------------------------------

sub cmd_script {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Replace ~ with home directory
	$file =~ s/~/$ENV{HOME}/g;

	# Open script file
	open("SCRIPT", "< $file")
		|| return error("cannot open file for reading: $file");
	

	# Read script file line by line, and add to "todo"
	my $todo = $self->var('todo', []);
	while (my $line = <SCRIPT>) {
		# Ignore comments and blank lines
		if (! ($line =~ /^\s*$/)) {
			push @$todo, $line;
		} 
	}

	# Close file, call resume, and return
	close("SCRIPT");
	$self->cmd_resume($graph, 0);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_server.pl
## ------------------------------------------------------------

sub cmd_server {
	my $self = shift;

	# Store server directory
	$self->var('server', shift);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_shell.pl
## ------------------------------------------------------------

sub cmd_shell {
	my $self = shift;
	my $cmd = shift;

	# Execute shell command
	my $status = system($cmd);

	# Exit
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_shift.pl
## ------------------------------------------------------------

sub cmd_shift {
	my $self = shift;
	my $graph = shift;
	my $key = shift || "?";
	my $node = shift || "0";
	my $shift = shift || "0";

	# Test that $graph is an alignment
	if (! UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		error("shift command only works on alignments");
		return 1;
	}

	# Test that alignment key $key is legal
	if (! exists($graph->{'graphs'}{$key})) {
		error("illegal alignment file key $key");
		return 1;
	}

	# Process shift
	$graph->shift_edges($key, $node, $shift);
	
	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_show.pl
## ------------------------------------------------------------

sub cmd_show {
	my $self = shift;
	my $graph = shift;
	my $args = (shift() || "") . " ";
	my $option = shift() || "";
	my $imid = shift();

	# Calculate ranges to show
	my ($imin, $imax) = (-1, -1);
	my $include = {};
	my $exclude = {};

	# Process argument string
	while ($args !~ /^\s*$/) {
		if ($args =~ s/^\s*([0-9]+)(-([0-9]+))?([^0-9])/$4/) {
			$imin = ($imin == -1) 
				? $1 + $graph->offset() 
				: min($imin, $1 + $graph->offset());
			$imax = max($imax, $3 + $graph->offset()) if (defined($3));
		} elsif ($args =~ s/^\s*([+-])([0-9]+)(-([0-9]+))?([^0-9])/$5/) {
			my ($ie, $i1, $i2) = ($1, $2, $4 || $2);
			$imin = min($imin, $i1 + $graph->offset()) if ($ie eq "+");
			$imax = max($imax, $i2 + $graph->offset()) if ($ie eq "+");

			# Update include/exclude hash within $imin and $imax
			my $i = $i1;
			for(my $i = $i1; $i <= min($imax, $i2); ++$i) {
				$include->{$i} = 1 if ($ie eq "+");
				$exclude->{$i} = 1 if ($ie eq "-");
			}
		} else {
			$args =~ s/^.//;
		}
	}

	# Process all included nodes, if -yield or -component option is given
	if ($option =~ /^-[cy]$/) {
		# Process all include nodes
		my $new = {};
		foreach my $i (keys(%$include)) {
			if ($option =~ /^-y/) {
				$graph->yields($new, $i);
			} elsif ($option =~ /^-c/) {
				$graph->component($i, $new);
			}
		}

		# Add all new include nodes to $include and update $imin and $imax
		foreach my $i (keys(%$new)) {
			$include->{$i} = 1;
			$imin = ($imin == -1) ? $i : min($imin, $i);
			$imax = max($imax, $i);
		}
	}

	# Set new values of $imin and $imax in $graph, and redisplay
	$graph->var('imin', $imin);
	$graph->var('imax', $imax);
	$graph->var('imid', defined($imid) ? $imid + $graph->offset() : $imin);
	$graph->include(scalar(%$include) ? $include : undef);
	$graph->exclude(scalar(%$exclude) ? $exclude : undef);
	$self->cmd_return($graph);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_show_align.pl
## ------------------------------------------------------------

sub cmd_show_align {
	my $self = shift;
	my $graph = shift;
	my $args = (shift() || "") . " ";
	my $option = shift() || "";

	# Process argument string
	my @graphs = ($graph);
	while ($args !~ /^\s*$/) {
		my ($imin, $imax) = (-1, -1);
		if ($args =~ s/^\s*(=?)([a-z])([-+]?[0-9]+)(\.\.([+-]?[0-9]+))?([^0-9])/$6/) {
			# Retrieve values
			my $key = $2;
			my $offset = $1 ? 0 : $graph->offset($key);
			my $keygraph = $graph->graph($key);
			next if (! $keygraph);

			# Compute $imin and $imax
			$imin = $3 + $offset;
			$imin = 0 if ($imin < 0);
			$imax = max($imax, $5 + $offset) if (defined($5));
			$imax = $graph->graph($key)->size()
				if ($imax < 0);

			# Set values in graph and keygraph
			$graph->var("imin")->{$key} = $imin;
			$graph->var("imax")->{$key} = $imax;
			$keygraph->var("imin", $imin);
			$keygraph->var("imax", $imax);
			push @graphs, $keygraph if (! grep {$_ eq $keygraph} @graphs);
		} else {
			$args =~ s/^.//;
		}
	}

	# Redisplay all graphs and keygraphs
	#print "Updating " . join(" ", map {$_->id()} @graphs) . "\n";
	foreach my $g (@graphs) {
		$self->cmd_return($g);
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_sleep.pl
## ------------------------------------------------------------

sub cmd_sleep {
	my $self = shift;
	my $seconds = shift || "0";

	sleep($seconds);
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_stats.pl
## ------------------------------------------------------------

sub cmd_stats {
	my $self = shift;
	my $graph = shift;

	# Count number of nodes (comment/non-comment)

	# Count number of edges

	# Print 

}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_style.pl
## ------------------------------------------------------------

sub cmd_style {
	my $self = shift;
	my $graph = shift;
	my $style = shift;
	my $opt = shift || "";
	$opt .= " " if ($opt ne "");

	# Clear styles
	my $sparent = $self;
	$sparent = $graph if ($graph && $opt =~ s/^-graph\s+//);
	if ($style =~ /^-clear\s*$/) {
		$sparent->{'styles'} = {};
		return 1;
	}

	# PostScript equivalents
	my $color = { 
		'black' 	=> '0 setgray',
		'white' 	=> '1 setgray', 
		'gray'  	=> '0.5 setgray',
		'gray10'	=> '0.1 setgray',
		'gray20'	=> '0.2 setgray',
		'gray30'	=> '0.3 setgray',
		'gray40'	=> '0.4 setgray',
		'gray50'	=> '0.5 setgray',
		'gray60'	=> '0.6 setgray',
		'gray70'	=> '0.7 setgray',
		'gray80'	=> '0.8 setgray',
		'gray90'	=> '0.9 setgray',
		'red'   	=> '1 0 0 setrgbcolor',
		'green' 	=> '0 1 0 setrgbcolor',
		'blue'  	=> '0 0 1 setrgbcolor',
		'cyan'  	=> '0 1 1 setrgbcolor',
		'magenta'	=> '1 0 1 setrgbcolor',
		'yellow' 	=> '1 1 0 setrgbcolor',
		'darkred'	=> '0.5 0 0 setrgbcolor',
		'darkgreen'	=> '0 0.5 0 setrgbcolor',
		'darkblue'	=> '0 0 0.5 setrgbcolor',
		'lightred'	=> '1 0.5 0.5 setrgbcolor',
		'lightgreen'	=> '0.5 1 0.5 setrgbcolor',
		'lightblue'	=> '0.5 0.5 1 setrgbcolor',
	};
	my $dash = {
		'none' 		=> '', 'dash' 		=> '[4] 0 setdash',
		'dot'		=> '[2] 0 setdash',
	};
	my $fonttype = {
		'roman'		=> '',
		'bold'		=> '1 setfontstyle setupfont',
		'italic'	=> '2 setfontstyle setupfont',
		'bolditalic'=> '3 setfontstyle setupfont',
	};

	# Reset style $style
	$sparent->{'styles'}{$style}{'label'} = "";
	$sparent->{'styles'}{$style}{'arclabel'} = "";
	$sparent->{'styles'}{$style}{'arc'} = "";

	# Process options
	my $context = 'label';
	while ($opt) {
		if ($opt =~ s/^-label\s+//) {
			# -label
			$context = 'label';
		} elsif ($opt =~ s/^-arclabel\s+//) {
			# -arclabel
			$context = 'arclabel';
		} elsif ($opt =~ s/^-arc\s+//) {
			# -arc
			$context = 'arc';
		} elsif ($opt =~ s/^-ps\s+\"([^"]+)\"\s+// 
				|| $opt =~ s/^-ps\s+\'([^']+)\'\s+//) {
			# -ps $postscript
			$sparent->{'styles'}{$style}{$context} 
				.= $1 . " ";
		} elsif ($opt =~ s/^-color\s+(\S+)\s+//) {
			# -color $color
			my $s = $1;
			my $col = "";
			if ($color->{$s}) {
				$col = $color->{$s};
			} elsif ($s =~ /^gray\((1|1\.0*|0|0\.[0-9]*)\)$/) {
				$col = "$1 setgray";
			} elsif ($s =~ /^rgb\((1|1\.0*|0|0\.[0-9]*),(1|1\.0*|0|0\.[0-9]*),(1|1\.0*|0|0\.[0-9]*)\)$/) {
				$col = "$1 $2 $3 setrgbcolor";
			} 
			$sparent->{'styles'}{$style}{$context} 
				.= $col . " ";
		} elsif ($context ne "arc" && $opt =~ s/^-fonttype\s+(\S+)\s+//) {
			# -fonttype $fonttype
			$sparent->{'styles'}{$style}{$context} 
				.= ($fonttype->{$1} || "") . " ";
		} elsif ($context eq "arc" && $opt =~ s/^-dash\s+(\S+)\s+//) {
			# -dash $dash
			$sparent->{'styles'}{$style}{$context} 
				.= ($dash->{$1} || "") . " ";
		} elsif ($opt =~ s/^(\S+)?\s+//) {
			error("Illegal style option: $1");
		} else {
			$opt =~ s/^\s*$//;
		}
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_tell.pl
## ------------------------------------------------------------

sub cmd_tell {
	my $self = shift;
	my $table = shift;
	my $file = shift || "";

	if (! defined($table)) {
		$table = "$file";
		$table =~ s/\s+//g;
	}

	# Get table list
	my $tablenames = $self->{'tablenames'} = $self->{'tablenames'} || {};
    my $tables = $self->{'tables'} = $self->{'tables'} || [];

	# Close old table with given name, if it exists
	$self->cmd_told($table);

	# Open new filehandle and register as table
	$file =~ s/^~/$ENV{HOME}/g;
	open(my $fh, ">:encoding(utf8)", $file)
		|| ( warning("cannot open file \"$file\" for writing") && return 1);
	push @$tables, $fh;
	$tablenames->{$table} = $fh;

	# Info
	inform("Opened file \"$file\" as stream \"$table\"")
		if (! $self->quiet());

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_text.pl
## ------------------------------------------------------------

sub cmd_text {
	my $self = shift;
	my $graph = shift;
	my $i1 = shift;
	my $i2 = shift;
	my $digits = shift;
	$digits = (defined($digits) && $digits);
	my $unicode = 1;

	# Ensure i2 and i2 are defined
	$i1 = "=0" if (! defined($i1));
	$i2 = "=" . ($graph->size()-1) if (! defined($i2));

	# Print text
	print $graph->words($graph->pos2apos($i1), $graph->pos2apos($i2), " ",
		$digits, $unicode)
		. "\n";

	# Return	
	return 1;	
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_title.pl
## ------------------------------------------------------------

sub cmd_title {
	my $self = shift;
	my $graph = shift;
	my $text = shift;

	# Create title automatically, if requested
	if ($text =~ /^\s*-auto\s*$/) {
		# Create title automatically
		my $fname = $graph->file() || "UNTITLED";
		$text = $fname . " on " . `date` . "(offset "
			. $graph->offset() . ")";
	} 

	if ($text =~ /^\s*-off\s*$/) {
		$text = undef;
	}

	$graph->var('title', $text);
	print "title=" . ($graph->var('title') || "UNTITLED") . "\n";
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_told.pl
## ------------------------------------------------------------

sub cmd_told {
	my $self = shift;
	my $table = shift;
	
	# Find table data
	my $tablenames = $self->{'tablenames'} = $self->{'tablenames'} || {};
	my $tables = $self->{'tables'} = $self->{'tables'} || [];

	# Find last defined table if $table is undefined
	if (! $table) {
		return 1 if ($#$tables < 0);
		my $lfh = $tables->[$#$tables];
		foreach my $t (keys(%$tablenames)) {
			$table = $t if ($tablenames->{$t} eq $lfh);
		}
	}
	return 1 if (! defined($table));

	# Find file handle
	my $fh = $self->{'tablenames'}{$table};

	# Close table
	if ($fh) {
		$self->{'tables'} = [grep {$_ ne $fh} @{$self->{'tables'}}];
		delete $self->{'tablenames'}{$table};
		close($fh);
		inform("Closing stream \"$table\"")
			if (! $self->quiet());
	}

	# Return 1
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_touch.pl
## ------------------------------------------------------------

sub cmd_touch {
	my $self = shift;
	my $graph = shift;

	# Touch graph
	$graph->mtime(1);

	# Return 
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_transfers.pl
## ------------------------------------------------------------

# cmd_transfers($self, $graph, $clear, $savedir, $files): extract 
# transfer rules from the files matching $files; save the current
# transfer lexicon in $savedir; and possibly clear the current transfer
# lexicon

sub cmd_transfers {
	# Read input arguments
	my ($self, $graph, $clear, $savedir, $filenames) = @_;

	# Clear current transfer lexicon
	$self->{'translex'} = {} if ($clear);

	# Check that $graph is an alignment
	if (! UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		error("current graph is not an alignment");
		return 1;
	}

	# Process files in $filenames
	my @files = split(/\s+/, $filenames);
	if (@files) {
		error("transfers: multiple filenames not supported yet");
	} else {
		# Process current graph
		$graph->extract_translex($self);
	}

	# Save transfer lexicon if $savedir specified
	if ($savedir) {
		# Save...
		error("transfers: saving not supported yet");
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_undiff.pl
## ------------------------------------------------------------

sub cmd_undiff {
	my $self = shift;
	my $graph = shift;

	# Delete all edges marked as 'diff' in the graph
 	$graph->do_edges(
		sub {
			$_[1]->edge_del($_[0])
				if ($_[0]->var('diff'));
		},
		$graph);

	# Reset styles and layout for graph
	delete $graph->{'styles'};
	delete $graph->{'layout'};

	# Update graph
	$self->cmd_return($graph);

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_user.pl
## ------------------------------------------------------------

sub cmd_user {
	my $self = shift;
	my $user = shift;

	# Try to set user from $ENV{'USER'}
	my $username = $ENV{'USER'} || "unknown";

	# Try to read user from command options
	if ($user =~ /^-f\s+(\S+)\s*$/) {
		my $userfile = $1;
		if ( -r $userfile) {
			$username = `cat $userfile` || "none";
			chomp($username);
		} else {
			warning("Non-existent file $userfile\n");
		}
	} elsif ($user =~ /^\s*(\S+)\s*$/) {
		$username = $user;
	}

	# Set username
	$self->var("user", $username);

	# Print user and exit
	print "User: " . $self->var("user") . "\n";
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_vars.pl
## ------------------------------------------------------------

sub cmd_vars {
	my $self = shift;
	my $graph = shift;
	my $varstr = shift;

	# Check printing
	my $print = 0;
	$print = 1 if ($varstr =~ s/^\+print\s*//);

	# Read off variables from input string
	while ($varstr) {
		if ($varstr =~ s/^-(\S+)\s*//) {
			# Delete variable
			delete $graph->vars()->{$1};
		} elsif ($varstr =~ s/^(\S+):(\S+)\s*//) {
			# Add variable and abbreviation
			$graph->vars()->{$1} = $2;
		} elsif ($varstr =~ s/^(\S+)\s*//) {
			# Add variable with no abbreviation
			$graph->vars()->{$1} = undef;
		} else {
			# Remove uninterpretable input until next blank
			$varstr =~ s/^\S+\s*//;
		}
	}

	# Convert each variable to printable string
	my @vars = ();
	foreach my $var (sort(keys %{$graph->vars()})) {
		my $abbrev = $graph->vars()->{$var};
		push @vars, $var . ($abbrev ? " [$abbrev]" : "");
	}

	# Print variables
	if (! $self->quiet() || $print) {
		print "variables: " . join(", ", @vars). "\n";
		print "current graph is " . ($graph->{'vars.sloppy'} ? "sloppy" : "strict" ) . " with respect to unseen variables\n";
	}

	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_view.pl
## ------------------------------------------------------------

sub cmd_view {
	my $self = shift;
	my $graph = shift;
	my $i1r = shift;
	my $i2r = shift;

	my $i1 = (! defined($i1r) || $i1r eq "") 
		? 0 
		: max($i1r + $graph->offset(), 0);
	my $i2 = defined($i2r) 
		? $i2r + $graph->offset() 
		: $graph->size()-1;
	$i2 = min($i2, $graph->size()-1);
	
	Node->use_color(1) if (! $self->quiet());

	# Print nodes
	for (my $i = $i1; $i <= $i2; ++$i) {
		print print_node($graph, $i);

		# Abort if requested
		return 1 if ($self->abort());
	}	

	Node->use_color(0);
	return 1;
}

sub print_node {
	my $graph = shift;
	my $pos = shift;
	my $N = $graph->node($pos);

	my $rpos = $pos - $graph->offset();

	return (($graph->offset() && $rpos >= 0) ? "+$rpos" : "$rpos") 
		. ($N->comment() ? "| " : ": ")
		. $N->xml($graph, 0, 1) . "\n";
}

sub min {
	my $min = shift;
	foreach my $e (@_) {
		$min = $e if (0+$e < $min);
	}
	return $min;
}

sub max {
	my $max = shift;
	foreach my $e (@_) {
		$max = $e if (0+$e > $max);
	}
	return $max;
}
			

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_view_align.pl
## ------------------------------------------------------------

sub cmd_view_align {
	my $self = shift;
	my $graph = shift;
	my $nodestr = shift;

	# Check node argument
	$nodestr =~ /^([a-z])([0-9]+)$/;
	my ($key, $node) = ($1, $2);
	return 0 if (! (defined($1) && defined($2)));
	$node += $graph->offset($key) || 0;

	# Print alignment edges attached to given node
	my @edges = map {$graph->edge($_)} @{$graph->node_edges($key, $node)};
	foreach my $edge (@edges) {
		print $edge->string($graph->{'offsets'});
	}
	print "\n";
	return 1;

}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_viewer.pl
## ------------------------------------------------------------

sub cmd_viewer {
	my $self = shift;
	my $graph = shift;
	my $option = shift || "";
	#print "option: $option\n";

	# Specify new follow file
	$self->{'viewer'} = 1;
	++$viewer;
	my $fpsfile = "/tmp/dtag-$$-$viewer.ps";
	my $fpsfiles = {"" => $fpsfile};
	if ($graph->var("example") || $option eq "-e" || $option eq "-example") {
		$self->var("exfpsfile", $fpsfile);
		$graph = $self->var("examplegraph") || DTAG::Graph->new($self)
			if (! $graph->var("example"));
	} elsif ($option =~ /^-a/ && $graph->is_alignment()) {
		# Add fpsfiles for subgraphs
		delete $fpsfiles->{""};
		$fpsfiles->{":"} = $fpsfile;
		foreach my $key (sort(keys(%{($graph->graphs())}))) {
			my $f = "/tmp/dtag-$$-$viewer-$key.ps";
			my $subgraph = $graph->graph($key);
			$subgraph->fpsfile($f);
			$self->fpsfile($key, $f);
			$graph->fpsfile($key, $f);
			$fpsfiles->{":" . $key} = $f;
			#print "Subgraph: $subgraph $f\n";
			$self->cmd_return($subgraph);
		}
	}

	# Add fpsfile
	$self->fpsfile("", $fpsfile);
	$graph->fpsfile($fpsfile);

	# Record fpsfile as a viewed file
	$self->{'viewfiles'} = {} 
		if (! defined($self->{'viewfiles'}));
	map {$self->{'viewfiles'}->{$fpsfiles->{$_}} = 1} keys(%$fpsfiles);

	# Update graph and viewer
	$self->cmd_return($graph);

	# Call viewer on $fpsfile
	foreach my $key (sort(keys(%$fpsfiles))) {
		my $f = $fpsfiles->{$key};
		my $viewcmd = "" . ($self->option('viewer' . $key)
			|| $self->option('viewer') 
			|| 'gv $file &');
		$viewcmd =~ s/\$file/$f/g;
		print "opening viewer with \"$viewcmd\"\n" if ($self->debug());
		system($viewcmd);
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_webmap.pl
## ------------------------------------------------------------

sub cmd_webmap {
	my $self = shift;
	my $graph = shift;
	my ($tagvar, $wikidir, $exdir, $termexcount, $excount, $mincount, $url) 
		= @_;

	$tagvar = 'msd' if (! defined($tagvar));
	$wikidir = 'treebank.dk/map' if (! defined($wikidir ));
	$exdir = $wikidir if (! defined($exdir ));
	$termexcount = 10 if (! defined($termexcount ));
	$excount = $termexcount if (! defined($excount));
	$mincount = 2 if (! defined($mincount));
	$url = ".." if (! defined($url));

	# Debug
	print 'usage: webmap $tagvar $wikidir $exampledir $terminalExampleCount $ExampleCount $MinimalCount'; 
	print "\n";
	print "language must be encoded in '_lang' feature\n\n";
	print "running: webmap $tagvar $wikidir $exdir $termexcount $excount $mincount $url\n";

	# Issue command
	$graph->wikidoc($tagvar, $wikidir, $exdir, $termexcount, $excount, 
		$mincount, $url);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/compound_autonumber.pl
## ------------------------------------------------------------

sub compound_autonumber {
	my $compound = shift;
	$compound = "" if (! defined($compound));
	$compound = decode_utf8($compound);

	# Counter characters
	my $odigit = "^";
	my $ldigits = ["¹", "²", "³", "⁰"];
	my $digits = join("", @$ldigits) . $odigit;

	# Insert spaces before all segment identifiers
	$compound =~ s/([^$digits\|])([$digits]+)/$1\|$2/g;

	# Split compound into segments
	my @segments = split(/\|/, $compound);

	# Compute identifier for each segment
	my @ids = ();
	for (my $i = 0; $i <= $#segments; ++$i) {
		if ($segments[$i] =~ /^([$digits]+)/) {
			$ids[$i] = $1 || "";
		} else {
			$ids[$i] = "";
		}
	}

	# Process compound string
	if (! $ids[0]) {
		# Compound does not have any identifiers: renumber segments
		if (scalar(@segments) > 1) {
			$compound = "";
			for (my $i = 0; $i <= $#segments; ++$i) {
				$compound .= ($odigit x int($i / 3)) 
					. $ldigits->[$i % 3] . $segments[$i];
			}
		}
	} else {
		# Compound already contains identifiers: split identifiers
		my $prefix = "";
		my $count = 0;
		for (my $i = 0; $i <= $#segments; ++$i) {
			if ($ids[$i]) {
				# Segment is numbered: split numbering if next
				# segment is unnumbered; otherwise unchanged
				$prefix = $ids[$i];
				$count = 0;
				if ($i < $#segments && (! $ids[$i + 1])) {
					$segments[$i] =~ s/[$digits]//g;
					$segments[$i] = $prefix . $ldigits->[0] . $segments[$i];
					++$count;
				}
			} else {
				# Segment is unnumbered: add number to prefix
				$segments[$i] = $prefix . ("$odigit" x int($count / 3)) 
					. $ldigits->[$count % 3] . $segments[$i];
				++$count;
			}
		}
		$compound = join("", @segments);
	}
	
	return encode_utf8($compound);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/debug.pl
## ------------------------------------------------------------

sub debug {
	my $self = shift;
	return $self->var("debug", @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/default.pl
## ------------------------------------------------------------

sub default {
	while (my $value = shift) {
		return $value if (defined($value));
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/demorph.pl
## ------------------------------------------------------------

# sub demorph {
# 	my $morph = shift;
# 	my $string = "";
# 	while ($morph) {
# 		# Perform operation
# 		if ($morph =~ s/^\[//) {
# 			# Find first matching "]"
# 			my $level = 1;
# 			my $pos = 0;
# 			while ($level > 0 && $pos < length($morph)) {
# 				my $c = substring($morph, $pos++, 1);
# 				if ($c eq "[") {
# 					++$level;
# 				} else if ($c eq "]") {
# 					--$level;
# 				}
# 			}
# 
# 			$string .= demorph(substr($morph, 0, $pos));
# 
# 		# Remove relation name
# 		$m =~ s/^([^/]*)\/.*$/\1/g;
# 
# 		# Perform action
# 		if ($m =~ /^(!+)([^!]*)$/) {
# 			# Deletion "!" with suffix
# 			my $del = length($1);
# 			my $suff = $2;
# 			$string = substr($string, 0, length($1));
# 		}
# 	}
# }
# 
# sub demorph_split {
# 	my $morph = shift;
# 
# 	# Find first part of morpheme (after calling demorph to substitute brackets
# 	# with substrings
# 	my $level = 0;
# 	for (my $i = 0; $i < length($morph); ++$i) {
# 		
# 	}
# 
# 
# 
# 
# # Commands:
# 
# 	demorph($string, $morph):
# 		return ($string2, $morph2);
# 
# 	Rewrite rules:
# 
# 		# X "/" Y => X
# 		if ($morph =~ /^(.*)\/[^\/]*$/) {
# 			# Strip trailing "/" part
# 			return ($string, $1);
# 		} else if ($morph =~ /^(!+)(.*)$/) {
# 			# Apply deletions
# 			$string = substr($string, 0, length($string) - length($1));
# 			return ($string, length($2) > 0 ? "+" . $2 : ""); 
# 		} else if ($morph =~ /^-
# 		# 
# 		# "!+" X => "!+" +X
# 		s/^(!+)(.+)$/
# 		X/Y			=> X
# 		!*[Y]		=> !* +X +[Y]
# 		+X[Y]W		=>
# 		
# 	!*X[Y]/Z		=> !*
# 	!*X/Z			=> 
# 	+X[Y]/W  		=> +X +[Y] +Z
# 	+X/W			=> +X
# 	-X[Y]Z/W		=> -Z -[Y] -X
# 	-X/W			=> -X
# 
# 
# 	"!!!!SUFFIX"
# 	"+SUFFIX"
# 	"-PREFIX"
# 	"-P
# 

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/do.pl
## ------------------------------------------------------------


sub do {
	my $self = shift;
	my $cmdstr = shift;
	my $history = shift;
	my $success = undef;

	# Log command
	my $cmdlog = $self->var("cmdlog");
	if (defined($cmdlog) && ! $self->quiet()) {
		my $time = time() - ($self->var("cmdlog.time0") || 0);
		print $cmdlog encode_utf8("$time:\t$cmdstr\n");
	}

	# ---------- COMMANDS IN SORTED ORDER ----------

	# Find list of commands to process
	my $commands = [];
	if ($cmdstr =~ /^\s*macro/) {
		# Macros are always interpreted as a single command
		push @$commands, $cmdstr;
	} else {
		if ($cmdstr eq "") {
			push @$commands, "";
		} else {
			push @$commands, split(";;", $cmdstr);
		}
	}

	# Process commands
	my $todo = $self->var('todo');
	my $cmd;
	while (defined($cmd = shift(@$commands))) {
		my $graph = $self->graph();
		# Command ends with backslash
		if ($cmd =~ /\\\s*$/) {
			# Prepend command to following command
			$cmd =~ s/\\\s*$//;
			if (@$commands) {
				$commands->[0] = $cmd . " " . $commands->[0];
			} elsif (@$todo) {
				$todo->[0] = $cmd . " " . $todo->[0];
			}

			# Goto next command in loop
			next();
		}

		# Exit if $cmd is undefined (ctrl-D)
		if (! defined($cmd)) {
			$cmd = "exit";
			print "\n";
			$success = $self->cmd_exit($graph);
		}

		# Ignore comments starting with '#'
		$success = 1 
			if ($cmd =~ /^\s*#.*$/);

		# Update graph: <return>
		$success = $self->cmd_return($graph)
			if ($cmd =~ /^\s*$/);

		# Replace: =$replacement
		$success = $self->cmd_replace($graph, $1)
			if ($cmd =~ /^=(.*)\s*$/);

		# Macro: macro $macro $cmd
		$success = $self->cmd_macro($1, $2) 
			if ($cmd =~ /^\s*macro\s+(\w+)\s+(.*)$/ ||
				$cmd =~ /^\s*macro\s+(\w+)\s*$/);

		# Unix shell: ! $cmd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*!\s*(.*)$/);

		# Replace variables in command
		my $DTAGHOME = $ENV{'DTAGHOME'} || '$DTAGHOME';
		my $CDTHOME = $ENV{'CDTHOME'} || '$CDTHOME';
		my $HOME = $ENV{'HOME'} || '$HOME';
		$cmd =~ s/\$DTAGHOME/$DTAGHOME/g;
		$cmd =~ s/\$CDTHOME/$CDTHOME/g;
		$cmd =~ s/\$HOME/$HOME/g;

		# Help search relation command: ??$relation
		$success = $self->cmd_relhelpsearch($graph, $1) 
			if ($cmd =~ /^\s*\?\?(\S+)\s*$/);

		# Help relation command: ?$relation
		$success = $self->cmd_relhelp($graph, $2, $1) 
			if ($cmd =~ /^\s*\?(!)?([^?]\S+)\s*$/);

		# UNIX commands recognized by DTAG: ls mkdir rmdir rm pwd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*((mkdir|rmdir|rm|pwd)(\s+.*)?)$/);
		$success = $self->cmd_shell("ls --color " . ($1 || ""))
			if ($cmd =~ /^\s*ls(\s+.*)?$/);

		# Adiff: adiff $file1 ... $fileN
		$success = $self->cmd_adiff($graph, $1)
			if ($cmd =~ /^\s*adiff\s+(.*)$/);

		# Afilter: afilter $alignmentfile
		$success = $self->cmd_afilter($graph, $1)
			if ($cmd =~ /^\s*afilter\s+(\S+)\s*$/);

		# Alearn: alearn $options
		$success = $self->cmd_alearn($graph, $1) 
			if ($cmd =~ /^\s*alearn\s*(.*)\s*$/);

		# Align: align $nodes $type $nodes
		$success = $self->cmd_align($graph, $1, defined($3) ? $3 : "", $4)
			if (UNIVERSAL::isa($self->graph(), 'DTAG::Alignment') && (
				$cmd =~ /^\s*align\s+([a-z]?[0-9\.+-]+)\s+((\S+)\s+)?([a-z]?[\.0-9+-]+)\s*$/
				|| $cmd =~ /^\s*([a-z]?[\.0-9+-]+)\s+((\S+)\s+)?([a-z]?[\.0-9+-]+)\s*$/));

		# Alignment: alignment $file1 ... $fileN
		$success = $self->cmd_alignment($1)
			if ($cmd =~ /^\s*alignment\s+(.*)$/);

		# Aparse: aparse $alignmentfile
		$success = $self->cmd_aparse($graph, $1, "da-en")
			if ($cmd =~ /^\s*aparse\s+(\S+)\s*$/);
		$success = $self->cmd_aparse($graph, $2, $1)
			if ($cmd =~ /^\s*aparse\s+-(\S+)\s+(\S+)\s*$/);

		# As.example: as.example [$vars] [$from] [$to]
		$success = $self->cmd_as_example($graph, $2, $4)
			if ($cmd =~ /^\s*as.example\s*(\s+([^-+0-9]\S+))?(\s+(.*))?\s*$/);

		# Autoalign: autoalign $alexicon
		$success = $self->cmd_autoalign($graph, $2)
			if ($cmd =~ /^\s*autoalign\s*(\s+(.+))?\s*$/);

		# Autoevaluate: autoevaluate
		# start autoevaluation using current graph as gold standard
		$success = $self->cmd_autoevaluate($graph, $2)
			if ($cmd =~ /^\s*autoevaluate(\s+(\S+))?\s*$/);

		# Autogloss: autogloss [-atag $atagfile] [mapfile1] [mapfile2] ...
		$success = $self->cmd_autogloss($graph, $2, $3) 
			if ($cmd =~ /^\s*autogloss(\s+-atag\s+(\S*))?\s*(.*)$/);

		# Replace: autoreplace [-corpus] $rel1 $rel2 ...
		$success = $self->cmd_autoreplace($graph, $1, $2)
			if ($cmd =~ /^\s*autoreplace\s+(-corpus\s+)?(.*)$/);

		# Autotag: autotag $tag $filepattern
		if ($cmd =~ /^\s*autotag\s+-pos\s+([+-]?[0-9]+)\s*$/) {
			$self->autotag_setpos($graph, $1, -1);
			$self->cmd_autotag_next($graph);
			$success = 1;
		} elsif ($cmd =~ /^\s*autotag\s+-offset\s+([+-])?([0-9]+)\s*$/) {
			$self->cmd_offset($graph, $1, $2);
			my $pos = ($graph->var('autotagpos') || 0) - 1;
			$graph->var('autotagpos', $pos);
			$self->cmd_autotag_next($graph);
			$success = 1;
		} elsif ($cmd =~ /^\s*autotag\s+-off\s*$/) {
			$self->autotag_off($graph);
			$success = 1;
		} elsif ($cmd =~ /^\s*autotag\s+(\S+)(\s+(-matches))?(\s+(.*\S))?\s+$/) {
			$success = $self->cmd_autotag($graph, $1, $5, $3);
		}

		# Autotag assignment: "<value" and "pos<value"
		if ($cmd =~ /^<(.*)$/) {
			$success = $self->cmd_autotag_next($graph, $1)
		} elsif ($cmd =~ /^([+-]?[0-9]+)<(.*)$/) {
			$self->autotag_setpos($graph, $1);
			$success = $self->cmd_autotag_next($graph, $2);
		}
		
		# Change directory: cd $dir
		$success = $self->cmd_cd($1)
			if ($cmd =~ /^\s*cd\s+(.*\S)\s*$/);

		# Clear: clear [-tag|-lex|-edges]
		$success = $self->cmd_clear($graph, $2) 
			if ($cmd =~ /^\s*clear( (-lex|-tag|-edges))?\s*$/);

		# Close: close
		$success = $self->cmd_close($graph, $2)
			if ($cmd =~ /^\s*close(\s+(-all))?\s*$/);

		# Told: told [$name]
		$success = $self->cmd_told($2, $3) 
			if ($cmd =~ /^\s*told(@(\S+))?\s*$/);

		# Command log: cmdlog $file
		$success = $self->cmd_cmdlog($1)
			if ($cmd =~ /^\s*cmdlog\s+(.*\S)\s*$/);

		# Comment: comment $pos $dtag_code
		$success = $self->cmd_comment($graph, $1, $2) 
			if ($cmd =~ /^\s*comment\s*([0-9]+)?\s+(.*)$/);

		# Confusion: confusion [-add] $name $file...
		$success = $self->cmd_confusion($2, $3, $1) 
			if ($cmd =~ /^\s*confusion(\s+-add)?\s+(\S+)\s+(.*)$/);

		# Corpus: corpus $files
		$success = $self->cmd_corpus($1) 
			if ($cmd =~ /^\s*corpus(\s+.*)?$/);
		$success = $self->cmd_corpus_apply($1) 
			if ($cmd =~ /^\s*corpus-apply\s+(.*)$/);


		# Debug 
		if ($cmd =~ /^\s*debug\s*/) {
			$self->{'debug'} = 1;
			$success = 1;
		}

		# Delete node/edge/alignment edge: del $node[-$node] [$etype $node]
		#	"del 12"
		#	"del 12 land 13"
		# 	"del a12"
		#	"del 12..27"
		$success = $self->cmd_del($graph, $1, $3, $4) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') && (
				$cmd =~ /^\s*del\s+([+-]?[0-9]+(\.\.[+-]?[0-9]+)?)\s+(\S+)\s+([+-]?[0-9]+)\s*$/ ||
				$cmd =~ /^\s*del\s+([+-]?[0-9]+(\.\.[+-]?[0-9]+)?)\s*$/));
		$success = $self->cmd_del_align($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment') &&
				$cmd =~ /^\s*del\s+([a-z]-?[0-9]+)\s*$/);
		if ($cmd =~ /^\s*del\s+-on\s*$/) {
			$success = 1;
			print "Turning node deletion on\n";
			$graph->{'block_nodedel'} = 0;
		}
		if ($cmd =~ /^\s*del\s+-off\s*$/) {
			print "Turning node deletion off\n";
			$success = 1;
			$graph->{'block_nodedel'} = 1;
		}
		
		# Diff: diff $file
		$success = $self->cmd_diff($graph, $2)
			if ($cmd =~ /^\s*diff\s*(\s(\S*))?\s*$/);

		# Display: display $psfile
		$success = $self->cmd_display($graph, $1)
			if ($cmd =~ /^\s*display\s+(\S+)\s*$/);

		# Delete incoming edges at node: edel $node
		$success = $self->cmd_edel($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') && 
				$cmd =~ /^\s*edel\s+([+-]?[0-9]+)\s*$/);
		$success = $self->cmd_del($graph, $1, $2, $3, 1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') && (
				$cmd =~ /^\s*edel\s+([+-]?[0-9]+)\s+(\S+)\s+([+-]?[0-9]+)\s*$/));

		# Echo: echo $string
		$success = $self->cmd_echo($2, $3)
			if ($cmd =~ /^\s*echo(@(\S+))?\s(.*)$/);

		# Edges: edges $node
		$success = $self->cmd_edges($graph, $1)
			if ($cmd =~ /^\s*edges\s+(\S+)\s*$/
				|| $cmd =~ /^([a-z]?[0-9]+)\s*$/);

		# Edgesep: edgesplit regexp
		$success = $self->cmd_edgesplit($1) 
			if ($cmd =~ /^\s*edgesplit\s+(.*)$/);

		# Efilter: efilter ±label... ±
		$success = $self->cmd_efilter($graph, $1)
			if ($cmd =~ /^\s*efilter((\s+[+-]\S*)+)\s*$/);

		# Etypes: etypes -$type $type1 $type2 ...
		$success = $self->cmd_etypes($graph, $2, $3, $1)
			if ($cmd =~ /^\s*etypes\s+(-add\s+)?-(\S+)\s+(.*)$/ ||
				$cmd =~ /^\s*etypes\s*$/);

		# Edit node/edge: edit $node [$var[=$value]]
		#	"edit 12 gloss=him"
		#	"edit 12 in=12:subj|13:land"
		$success = $self->cmd_edit($graph, $1, $2) 
			if ($cmd =~ /^\s*edit\s+([+-]?[0-9]+)\s*(.*)\s*$/);

		# Errordef: errordef [-node|-edge] $name $code
		$success = $self->cmd_errordef($graph, $2, $3, defined($5) ? $5 : "") 
			if ($cmd =~ /^\s*errordef(\s+(-node|-edge))?\s+(\S+)(\s+(.*))?$/);

		# Errordefs: errordefs $name
		$success = $self->cmd_errordefs($graph, $1) 
			if ($cmd =~ /^\s*errordefs(\s+(\S+))?\s*$/);

		# Errors: errors [$node[-$node]]
		$success = $self->cmd_errors($graph, $2, defined($4) ? $5 : $2) 
			if ($cmd =~ /^\s*errors(\s+([+-]?[0-9]+)(\s*(-)\s*([-+]?[0-9]+))?)?\s*$/);

		# Gedit: gedit $lineno
		$success = $self->cmd_gedit($graph, $2) 
			if ($cmd =~ /^\s*gedit(\s+([0-9]+))?\s*$/);

		# Example: ex $specification
		$success = $self->cmd_example($graph, $1) 
			if ($cmd =~ /^\s*example\s+(.*)$/);

		# Exit: exit 
		#     : quit
		$success = $self->cmd_exit($graph, $1)
			if ($cmd =~ /^\s*exit(!)?\s*$/ || $cmd =~ /^\s*quit(!)?\s*$/);

		# Find: find $pattern
		$success = $self->cmd_find($graph, $1) 
			if ($cmd =~ /^\s*find\s+(.*\S)\s*$/);

		# Fixations fixations $fixgraphid $durattr $graphattr $fixattr
		$success = $self->cmd_fixations($graph, $1, $2, $3, $5)
			if ($cmd =~ /^\s*fixations\s+(\S+)\s+(\S+)\s+(\S+)(\s+(\S+))?\s*$/);

		# Follow: follow [$file]
		$success = $self->cmd_follow($graph, $1)
			if ($cmd =~ /^\s*follow\s*(\S*)\s*$/);

		# Format: format $var $regexp
		$success = $self->cmd_format($graph, $1, $2)
			if ($cmd =~ /^\s*format\s+([^ ]*)\s+(.*)$/ 
				|| $cmd=~ /^\s*format\s+([^ ]*)$/);

		# Frame: frame ... (ignored)
		$success = $self->cmd_title($graph, $3)
			if ($cmd =~ /^\s*frame((\s+-[^ ]+)*)\s+([^-].*)\s*$/);

		# Goto: goto [-next|-prev|$match]
		$success = $self->cmd_goto($graph, $1)
			if ($cmd =~ /^\s*goto\s+(.+)\s*$/);

		# Graph: graphs
		$success = $self->cmd_graphs($graph) 
			if ($cmd =~ /^\s*graphs\s*$/);

		# Help: help [$command]
		$success = $self->cmd_help($1) 
			if ($cmd =~ /^\s*help\s*(\S*)\s*$/);

		# Inalign: inalign 
		$success = $self->cmd_inalign($graph, $1, $3, $2)
			if ($cmd =~ /^\s*inalign\s+([0-9+]+)\s+(\S+)\s+([0-9+]+)\s*$/);
		$success = $self->cmd_inalign($graph, $1, $2, "")
			if ($cmd =~ /^\s*inalign\s+([0-9+]+)\s+([0-9+]+)\s*$/);

		# Inline: inline $pos $dtag_code
		$success = $self->cmd_inline($graph, $1, $2) 
			if ($cmd =~ /^\s*inline\s+([0-9]+)\s+(.*)$/);

		# Kgoto: kgoto $time
		$success = $self->cmd_kgoto($graph, $1) 
			if ($cmd =~ /^\s*kgoto\s+([0-9.]+)$/);

		# Kplay: kplay $time
		$success = $self->cmd_kplay($graph, $2, $5, $6) 
			if ($cmd =~ /^\s*kplay(\s+-speed=([0-9.]+))?(\s+(([0-9.]+)-)?([0-9.]+))?\s*$/);

		# Layout: layout $options
		$success = $self->cmd_layout($graph, $1)
			if ($cmd =~ /^\s*layout\s*(.*)\s*$/);

		# Lexicon: lexicon $name
		$success = $self->cmd_lexicon($1)
			if ($cmd =~ /^\s*lexicon\s+(\S*)\s*$/);

		# Load: load [-tag|-lex|-match] [-multi] [$file]
		$success = $self->cmd_load($graph, $2, $4, $3)
			if ($cmd =~ /^\s*load\s*((-lex|-tag|-atag|-key|-fix|-eye|-match|-tiger|-malt|-conll|-emalt)\s+)?(-multi\s+)?(\S*)\s*$/);

		# Lookup: lookup "$string"$
		$success = $self->cmd_lookup($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
				&& $cmd =~ /^\s*lookup\s+"(.*)"\s*$/);
		$success = $self->cmd_lookup($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
				&& $cmd =~ /^\s*lookup\s+(.*)\s*$/);
		$success = $self->cmd_lookup_align($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment') 
				&& $cmd =~ /^\s*lookup\s+(.*)\s*$/);

		# Lookup word: lookupw "$string"$
		$success = $self->cmd_lookupw($graph, $1) 
			if ($cmd =~ /^\s*lookupw\s+"(.*)"\s*$/);
		$success = $self->cmd_lookupw($graph, $1) 
			if ($cmd =~ /^\s*lookupw\s+(.*)\s*$/);

		# Macros: macros
		$success = $self->cmd_macros($1, $2) 
			if ($cmd =~ /^\s*macros\s*$/);

		# Maptags: maptags [-map $mapfile] $invar $outvar
		$success = $self->cmd_maptags($graph, $2, $3, $4)
			if ($cmd =~ /^\s*maptags(\s+-map\s+(\S+))?\s+(\S+)\s+(\S+)\s*$/);

		# Matches: matches
		$success = $self->cmd_matches($1)
			if ($cmd =~ /^\s*matches\s*(.*)$/);

		# Merge: merge $fileglob
		$success = $self->cmd_merge($graph, $1) 
			if ($cmd =~ /^\s*merge\s+(.+)$/);

		# Move node: move $pos1 $pos2
		$success = $self->cmd_move($graph, $1, $2)
			if ($cmd =~ /^\s*move\s+([0-9]+)\s+([0-9]+)\s*$/);

		# Multiedit: multiedit $node1-$node2 ...

		# New: new (create new graph)
		$success = $self->cmd_new()
			if ($cmd =~ /^\s*new\s*$/);

		# Noerror: mark noerror $2 for node $1 
		$success = $self->cmd_noerror($graph, $1, $3)
			if ($cmd =~ /^\s*noerror\s+([+-]?[0-9]+)(\s+(\S+))?\s*$/);

		# Next: next ... (shorthand for "goto next...")
		$success = $self->cmd_goto($graph, $cmd)
			if ($cmd =~ /^\s*next/);

		# Noedge: noedge $node
		$success = $self->cmd_noedge($graph, $1)
			if ($cmd =~ /^\s*noedge\s+([0-9]+)\s*$/);

		# Note: note $node $text
		$success = $self->cmd_note($graph, $1, $2)
			if ($cmd =~ /^\s*note\s+([0-9]+)\s*(.*)$/);

		# Note: notes
		$success = $self->cmd_notes($graph)
			if ($cmd =~ /^\s*notes\s*$/);

		# Offset: offset [=+-]$offset
		$success = $self->cmd_offset($graph, $2, $3)
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
				&& $cmd =~ /^\s*offset(\s+([-+=])?([0-9]+|end))?\s*$/);
		$success = $self->cmd_offset_align($graph, $1)
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment')
				&& $cmd =~ /^\s*offset((\s+([-+=])?([a-z]-?[0-9]+))*)\s*$/);
		$success = $self->cmd_offset_align($graph, "auto")
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment')
				&& $cmd =~ /^\s*offset\s+-auto\s*$/);

		# ok: ok
		$success = $self->cmd_ok($graph) 
			if ($cmd =~ /^\s*ok\s*$/);

		# Option: option $option=$value
		$success = $self->cmd_option($1, $2)
			if ($cmd =~ /^\s*option\s+(\S+)\s*=\s*(\S.*)\s*$/
				|| $cmd =~ /^\s*option\s+(\S+)\s+(\S.*)\s*$/
				|| $cmd =~ /^\s*option\s+(\S+)\s*$/);

		#if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
		#	$cmd =~ /^\s*oshow(\s+[+-]?[0-9]+)\s*$/) {
		#	my $offset = $1;
		#}

		# Tell: tell [-name=$name] $file
		$success = $self->cmd_tell($2, $3) 
			if ($cmd =~ /^\s*tell(@(\S+))?\s+(\S+)\s*$/);

		# parse2dtag: parse2dtag $ifile $ofile
		$success = $self->cmd_parse2dtag($1, $2) 
			if ($cmd =~ /^\s*parse2dtag\s+(\S+)\s+(\S+)\s*$/);

		# Partag: partag $key
		$success = $self->cmd_partag($graph, $1)
			if ($cmd =~ /^\s*partag\s+(\S*)\s*$/);

		# Patch: patch [-$key] $difffile
		$success = $self->cmd_patch($graph, $2, $3) 
			if ($cmd =~ /^\s*patch\s+(-([a-z])\s+)?(.*\S)\s*$/);

		# Pause: pause
		$success = $self->cmd_pause()
			if ($cmd =~ /^\s*pause\s*$/);

		# Perl: perl [$expr]
		$success = $self->cmd_perl($4, $3, $1, $2)
			if ($cmd =~ /^\s*perl\s*(-v)?\s*(-corpus)?\s*(-file)?\s+(.*)\s*$/);

		# Prev: prev* (shorthand for "goto prev*")
		$success = $self->cmd_goto($graph, $cmd)
			if ($cmd =~ /^\s*prev/);

		# Print: print [$file]
		$success = $self->cmd_print($graph, $3, 0, $2)
			if ($cmd =~ /^\s*print\s*((-i|-p)\s+)*(\S*)\s*$/);

		# Parse step: pstep $number
		$success = $self->cmd_pstep($graph, $2)
			if ($cmd =~ /^\s*pstep(\s+([-+0-9]+))?\s*$/);

		# Redirect: redirect <$file>
		$success = $self->cmd_redirect($2)
			if ($cmd =~ /^\s*redirect(\s+(\S+))?\s*$/);

		# Relations: relations
		$success = $self->cmd_relations($graph, $2)
			if ($cmd =~ /^\s*relations\s*(\s+([^ ]*))?$/);

		# Relset: relset $name [$csvfile]
		$success = $self->cmd_relset($graph, $2, $4) 
			if ($cmd =~ /^\s*relset(\s+(\S+))?(\s+(\S+))?\s*$/);

		# Relset2latex: relset2latex $filename [$type] ...
		$success = $self->cmd_relset2latex($graph, $2, $3) 
			if ($cmd =~ /^\s*relset2latex(\s+-file=(\S+))?\s+(.*)$/);

		# Resume: resume
		$success = $self->cmd_resume($graph, $2)
			if ($cmd =~ /^\s*resume(\s+([0-9]+))?\s*$/);

		# Save: save [$file]
		$success = $self->cmd_save($graph, $2, $3)
			if ($cmd =~ /^\s*save\s*(\s+(-lex|-tag|-atag|-alex|-xml|-malt|-match|-conll|-table)\s+)?(\S*)\s*$/);

		# Save: save -corpus $tablefile
		$success = $self->cmd_save_table($graph, $1, @{$self->{'corpus'}})
			if ($cmd =~ /^\s*save\s+-corpus\s*(\S+)\s*$/);

		# Script: script [$file]
		if ($cmd =~ /^\s*script\s+-q\s+(\S.*\S)\s*$/) {
			my $quiet = $self->quiet();
			$self->quiet(1);
			$success = $self->cmd_script($graph, $1);
			$self->quiet($quiet);
		} elsif ($cmd =~ /^\s*script\s*(\S.*\S)\s*$/) {
			$success = $self->cmd_script($graph, $1);
		}

		# Segment: segment $node [segment|segment|...] 
		$success = $self->cmd_compound($graph, $1, $2, $3)
			if ($cmd =~ /^\s*segment\s+([a-z])?([0-9]+)(.*)$/);
	
		# Server: server $directory
		$success = $self->cmd_server($1)
			if ($cmd =~ /^\s*server\s*(\S*)\s*$/);

		# Shell: shell $cmd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*shell\s+(.*)$/);

		# Shift: shift $anode $offset
		$success = $self->cmd_shift($graph, $1, $2, $3)
			if ($cmd =~ /^\s*shift\s+([a-z])([0-9]+)\s+([-+]?[0-9]+)\s*$/);

		# Show: show [-component] $imin1[..$imax1] $imin2[..$imax2]
		# $success = $self->cmd_show($graph, $3, $5)
		if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
			$cmd =~ /^\s*show(\s+(-c(omponent)?|-y(ield)?))?((\s+[+-]?[0-9]+(-[0-9]+)?)*)\s*$/) {
			$success = $self->cmd_show($graph, $5, $2);
		}
		if (UNIVERSAL::isa($graph, 'DTAG::Alignment') &&
			$cmd =~ /^\s*show(\s+(-c(omponent)?|-y(ield)?))?((\s+=?[+-]?[a-z][0-9]+(-[0-9]+)?)*)\s*$/) {
			$success = $self->cmd_show_align($graph, $5, $2);
		}

		# Sleep: sleep $time
		$success = $self->cmd_sleep($1) 
			if ($cmd =~ /^\s*sleep\s+([0-9]*(\.[0-9]*)?)\s*$/);

		# Step: step
		$success = $self->cmd_resume($graph, 1)
			if ($cmd =~ /^\s*step\s*$/);

		# Style: style $id $options
		$success = $self->cmd_style($graph, $1, $3) 
			if ($cmd =~ /^\s*style\s+(\S+)(\s+(.+))?\s*$/);

		# Table: table [-name=$name] $string
		$success = $self->cmd_table($2, $3)
			if ($cmd =~ /^\s*table(\s+-name=(\S+))?\s(.*)$/);

		# Text: text $i1 $i2
		$success = $self->cmd_text($graph, $2, $4, 0)
			if ($cmd =~ /^\s*text(\s+([+-=]?[0-9]+)(\s*\.\.\s*([+-=]?[0-9]+))?)?\s*$/);

		# Text: textn $i1 $i2
		$success = $self->cmd_text($graph, $2, $4, 1)
			if ($cmd =~ /^\s*textn(\s+([+-=]?[0-9]+)(\s*\.\.\s*([+-=]?[0-9]+))?)?\s*$/);

		# Title: title $title
		$success = $self->cmd_title($graph, $1)
			if ($cmd =~ /^\s*title\s+(.+)\s*$/);

		# Touch graph: touch
		$success = $self->cmd_touch($graph)
			if ($cmd =~ /^\s*touch\s*$/);

		# Transfers: transfers [-save $dir] [-clear] $files
		$success = $self->cmd_transfers($graph, $1, $3, $4) 
			if ($cmd =~ /^\s*transfers(\s+-clear)?(\s+-save\s+(\S+))?(.*)$/);

		# Undiff (reset diff): undiff
		$success = $self->cmd_undiff($graph)
			if ($cmd =~ /^\s*undiff\s*$/);

		# Unix shell: unix $cmd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*unix\s+(.*)$/);

		# User name: user [-f $file] $name
		$success = $self->cmd_user($1) 
			if ($cmd =~ /^\s*user\s+(.*\S)\s*$/);

		# Vars: vars [+$var[:$abbrev]] [-$var] ... 
		#	var +gloss:g +lexeme:x -glss
		if ($cmd =~ /^\s*vars\s+-sloppy\s*$/) {
			$graph->{'vars.sloppy'} = 1;
			$self->cmd_vars($graph, "");
			$success = 1;
		} elsif ($cmd =~ /^\s*vars\s+-strict\s*$/) {
			$graph->{'vars.sloppy'} = 0;
			$self->cmd_vars($graph, "");
			$success = 1;
		} elsif ($cmd =~ /^\s*vars(\s+)?(.*)?\s*$/) {
			$success = $self->cmd_vars($graph, $2) 
		}

		# View: view
		$success = $self->cmd_view($graph, $1, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
				$cmd =~ /^\s*view\s*([+-]?[0-9]+)?\s*$/);
		$success = $self->cmd_view($graph, $1, $2) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
				$cmd =~ /^\s*view\s+([0-9]+)-([0-9]+)\s*$/);
		$success = $self->cmd_view_align($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment') &&
				$cmd =~ /^\s*view\s+([a-z][0-9]+)\s*$/);

		# Viewer: viewer
		$success = $self->cmd_viewer($graph, $2) 
			if ($cmd =~ /^\s*viewer(\s+(-e(xample)?|-a(ll)?))?\s*$/);

		# Webmap
		$success = $self->cmd_webmap($graph, $2)
			if ($cmd =~ /^\s*webmap(\s+(\S.*))?$/);

	# ---------- MACROS ----------

		# Macro
		if ($cmd =~ /^\s*(\w+)\s*$/ || $cmd =~ /^\s*(\w+)\s+(.*)\s*$/) {
			my ($x1, $x2) = ($1, $2);
			$x2 = "" if (! defined($x2));
			my $cmd = $self->{'macros'}{$x1};
			my $cmd2 = $cmd || "";
			if ($cmd && $cmd2 =~ /{ARGS}/) {
				$cmd2 =~ s/{ARGS}/$x2/g;
			} elsif ($cmd) {
				$cmd2 .=  " " . ($x2 || "");
			}
			my $fname = $graph->file() || "UNTITLED";
			$cmd2 =~ s/{FILE}/$fname/g;
			if ($cmd) {
				$self->do($cmd2);
				$success = 1;
			}
		}

	# ---------- SPECIAL COMMANDS THAT MUST GO AT THE END ----------


		# Add node: [node] [$pos] $input [$var=$value] ...
		#	"node Han t=XP g=He x=han123 m=han"
		#	" Han t=XP g=He x=han123 m=han"
		if ($cmd =~ /^\s*node\s+-off\s*$/) {
			$success = 1;
			$graph->{'block_nodeadd'} = 1;
		} 
		if ($cmd =~ /^\s*node\s+-on\s*$/) {
			$success = 1;
			$graph->{'block_nodeadd'} = 0;
		}
		$success = $self->cmd_node($graph, $1, $2, $3) 
			if ((! $success) && UNIVERSAL::isa($graph, 'DTAG::Graph') &&
				($cmd =~ /^\s*node\s*([+-]?[0-9]+)?\s+(\S+)((\s+\S+=\S+)*)\s*$/ ||
				$cmd =~ /^\s+()(\S+)\s+((\S+=\S+\s*)*)\s*$/ ||
				((! $success) && $cmd =~ /^\s+()(\S+)()\s*$/)));
	
		# Add edge: [edge] $nodein $etype $nodeout
		#	"edge 12 subj 23"
		#	"12 land 23"
		$success = $self->cmd_edge($graph, $1, $2, $3) 
			if (UNIVERSAL::isa($self->graph(), 'DTAG::Graph') && (
				$cmd =~ /^\s*([+-]?[0-9]+)\s+(\S+)\s+([+-]?[0-9]+)\s*$/ || 
				$cmd =~ /^\s*edge\s+([+-]?[0-9]+)\s+(\S+)\s+([+-]?[0-9]+)\s*$/));

		# Unrecognized input
		error("unrecognized command: $cmd") if (! defined($success));

		# Save command in history, if successful and requested
		$self->term()->addhistory($cmd) if (defined($success) && $history);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/dump.pl
## ------------------------------------------------------------

sub dump {
	my $self = shift;
	my $obj = shift;

	# Find class of object
	my $ref = ref($obj) || "";
	my $pre = "";
	my $post = "";
	if ($ref && $ref !~ /^(ARRAY|HASH|CODE)$/) {
		$pre = "bless( ";
		$post = ", $ref )";
	}

	# Process object recursively
	if (! $ref) {
		return defined($obj) ? qq("$obj") : "undef";
	} elsif (UNIVERSAL::isa($obj, "ARRAY")) {
		return "$pre" . "[" 
			. join(", ", map {$self->dump($_)} @$obj) 
			. "]$post";
	} elsif (UNIVERSAL::isa($obj, "HASH")) {
		return "$pre" . "{"
			. join(", ", map {(defined($_) ? qq("$_") : "undef") . " => " . 
				$self->dump($obj->{$_})} sort(keys(%$obj))) 
			. "}$post";
	} elsif (UNIVERSAL::isa($obj, "CODE")) {
		return $pre . "sub { \"DUMMY\" }" . $post;
	} 

	# Return unknown if all else fails
	return "__UNKNOWN__";
}
	

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/dumper.pl
## ------------------------------------------------------------

sub dumper {
	Dumper(@_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/edge_filter.pl
## ------------------------------------------------------------

sub edge_filter {
	my $self = shift;
	my $string = shift;

	my $table = $self->var("edgefilters");
	$self->var("edgefilters", $table = {}) if (! defined($table));

	# Use existing filter, if present
	my $filter = $table->{$string};
	return $filter if (defined($filter));

	# Create new filter
	my $xstring = $string ? " $string " : "  ";
	$filter = $table->{$string} = 
		$self->query_parser()->RelationPattern(\$xstring);
	#print "Defined filter: $filter\n";
	return $filter;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/edge_setdiff.pl
## ------------------------------------------------------------

sub edge_setdiff {
	# Find all edges on $list1 which are not on $list2
	my $list1 = shift || [];
	my $list2 = shift || [];
	my $sep = shift;
	my $diff = [];

	# Compare edge lists
	foreach my $e1 (@$list1) {
		my $found = 0;
		foreach my $e2 (@$list2) {
			if ($e1->eq($e2)) {
				$found = 1;
				last;
			}
		}
		if (! $found) {
			push @$diff, $e1;
			printf "%s %s %s %s\n", 
				$sep, $e1->in(), $e1->type(), $e1->out();
		}
	}

	# Return edges in $list1 not found in $list2
	return $diff;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/error.pl
## ------------------------------------------------------------

sub error {
	print "\aERROR! " . join("", @_) . "\n";
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/errordefs.pl
## ------------------------------------------------------------

# Return error definitions sorted by increasing priority
sub errordefs {
	my $self = shift;

	# Ensure error definitions exist
	my $errordefs = $self->{'errordefs'};
	if (! defined($errordefs)) {
		$self->{'errordefs'} = $errordefs = {
			'@node' => [], '@edge' => [],
			'node' => {}, 'edge' => {}
		};
	}

	# Return error definitions
	return $errordefs;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/find_key.pl
## ------------------------------------------------------------

# Example: $I->find_key($graph, $match, $key)

sub find_key {
	# Arguments
	my $self = shift;
	my $graph = shift;
	my $match = shift;
	my $key = shift;

	# Parse $key
	my $string = "";
	my ($node, $n1, $n2, $e);
	while ($key) {
		if ($key =~ s/^\&yield\[\]\((\$\w+(,\$\w+)*)\)//
				|| $key =~ s/^\&yield// ) {
			
		} elsif ($key =~ s/^\&edges\(\$(\w+),\$(\w+)\)//) {
			my $n1 = $match->{'$' . $1};
			my $n2 = $match->{'$' . $2};
			$node = $graph->node($n1);
			$string .= join("|", map {($_->type() || "?")} 
				(grep {$_->out() == $n2} @{$node->in()}));
		} elsif ($key =~ s/^\$(\w+)\[~(\w+)\]//) {
			$node = $graph->node($match->{'$' . $1});
			$string .= ($graph->reformat($self, $2, $node->var($2)))
				if ($node);
		} elsif ($key =~ s/^\$(\w+)\[(\w+)\]//) {
			$node = $graph->node($match->{'$' . $1});
			$string .= ($node->var($2) || "") if ($node);
		} elsif ($key =~ s/^\$(\w+)//) {
			$node = $graph->node($match->{'$' . $1});
			$string .= ($node->var('_input') || "") if ($node);
		} elsif ($key =~ s/^([^\$\&]*)//) {
			$string .= $1;
		} elsif ($key =~ s/^\$\$//) {
			$string .= '$';
		} else {
			$string .= '$';
			$key =~ s/^\$//;
		}
	}

	# Return string
	return $string;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/fpsfile.pl
## ------------------------------------------------------------

sub fpsfile {
	my $self = shift;
	my $type = shift;
	$type = "" if (! defined($type));
	return $self->var('fpsfile:' . $type, @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/gid2index.pl
## ------------------------------------------------------------

sub gid2index {
	my $self = shift;
	my $graphid = shift;

	# Find graph matching graph_id
	for (my $i = 0; $i < scalar(@{$self->{'graphs'}}); ++$i) {
		if ($self->{'graphs'}[$i]->id() eq $graphid) {
			return $i;
		}

		# Abort if requested
		last() if ($self->abort());
	}

	# Not found
	return undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/goto_graph.pl
## ------------------------------------------------------------

sub goto_graph {
	my $self = shift;
	my $graph = shift;

	# Set new graph, and update viewer
	if ($graph >= 0 && $graph < scalar(@{$self->{'graphs'}})) {
		$self->{'graph'} = $graph;
		$self->cmd_return();
	}

	# Print changed graph
	print $self->graph()->print_graph($self->{'graph'}, $self->{'graph'} + 1)
		unless ($self->quiet());
	
	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/goto_match.pl
## ------------------------------------------------------------

sub goto_match {
	my $self = shift;
	my $match = shift;

	# Find file and binding, and exit if non-existent
	$match = max(1, $match);
	my ($file, $binding) = $self->mid2mspec($match);
	if (! $file) {
		error("Non-existent match: $match");
		return ;
	}

	# Find graph
	$self->{'match'} = $match;
	my $graph = $self->graph();
	if (! ($graph && ($graph->file() || "") eq $file)) {
		$self->cmd_load($graph, undef, $file);
		$graph = $self->graph();
	}

	# Find position of first node in $binding
	my $minhash = {};
	foreach my $v (keys(%$binding)) {
		if ($v =~ /^\$/) {
			my $k = $self->varkey($binding, $v);
			my $n = $binding->{$v};
			$minhash->{$k} = $n if (
				defined($n) && 
				((! defined($minhash->{$k}))
					|| ($n =~ /^[0-9]+$/ && $n < $minhash->{$k})));
		}
	} 

	# Goto this position
	if (UNIVERSAL::isa($graph, "DTAG::Graph")) {
		my $min = $minhash->{""} || 0;
		$self->cmd_show($graph, $min - $self->var('goto_context'), "", $min);
	} elsif (UNIVERSAL::isa($graph, "DTAG::Alignment")) {
		$self->cmd_show_align($graph, join(" ", 
			map {"=" . $_ . ($minhash->{$_} 
				- $self->var('goto_context'))} sort(keys(%$minhash))));
	}

	# Print new match
	print $self->print_match($self->{'match'}, $file, $binding)
		unless ($self->quiet());

	# Return
	return;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/graph.pl
## ------------------------------------------------------------

sub graph {
	my $self = shift;
	$self->{'graph'} = shift if (@_);
	return $self->{'graphs'}[$self->{'graph'} || 0];
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/graphid.pl
## ------------------------------------------------------------

sub graphid {
	my $self = shift;
	my $graph = shift;

	my $graphs = $self->{'graphs'};
	for (my $i = $#$graphs; $i >= 0; --$i) {
		return $i + 1 if ($graphs->[$i] == $graph);
	}
	return 0;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/inform.pl
## ------------------------------------------------------------

sub inform {
	print join("", @_) . "\n";
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/init_layout.pl
## ------------------------------------------------------------

sub init_layout {
	my $self = shift;

    # Supply default layout procedures in interpreter:
    # stream|nstyles|estyles|pos|nhide|ehide
    my $sub = sub { return 0 };
    foreach my $t ('stream', 'nhide', 'ehide', 'pos') {
        if (! defined($self->{'layout'}{$t})) {
            $self->{'layout'}{$t} = $sub;
        }
    } 
    $sub = sub { return [] }; 
    foreach my $t ('nstyles', 'estyles') {
        if (! defined($self->{'layout'}{$t})) {
            $self->{'layout'}{$t} = $sub;
        }
    }

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/interactive.pl
## ------------------------------------------------------------

sub interactive {
	my $self = shift;
	return $self->var("interactive", @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/interpreter.pl
## ------------------------------------------------------------

sub interpreter {
	return $interpreter;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/is_relset_etype.pl
## ------------------------------------------------------------

sub is_relset_etype {
	my $self = shift;
	my $etype = shift;
	my $class = shift;
	
	# Find relset and info for $etype
	my $relset = shift || $self->relsets($self->relset());
	return 0 if (! defined($relset));
	my $info = $relset->{$etype};
	return 0 if (! defined($info));
	my $tparents = $info->[$REL_TPARENTS];
	return 0 if (! defined($tparents));

	# Find canonical name for class
	return 0 if (! $relset->{$class});
	my $classname = $relset->{$class}[$REL_SNAME];
	return $info->[$REL_SNAME] eq $classname 
		|| $tparents->{$classname};
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/keygraph.pl
## ------------------------------------------------------------

sub keygraph {
	my ($self, $graph, $bindings) = (shift, shift, shift);
	my @vars = @_;
	my $key = $self->varkey($bindings, @vars);
	my $var1 = shift(@vars);
	foreach my $var (@vars) {
		my $nkey = $self->varkey($bindings, $var);
		if ($key ne $nkey) {
			$self->error($graph, "Variables " . join(" ", $var1, @vars) 
				. " must have the same key, but didn't: "
				. $var1 . "@" . $key . ","
				. $var . "@" . $nkey);
		}
	}
	return $graph->graph($key);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/lexicon.pl
## ------------------------------------------------------------

sub lexicon {
	my $self = shift;
	return $self->var('lexicon', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/lexicon_file.pl
## ------------------------------------------------------------

sub lexicon_file {
	my $self = shift;
	return $self->var('lexicon_file', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/loop.pl
## ------------------------------------------------------------

sub loop {
	my $self = shift;
	my $line = "";

	# Increase loop count and create prompt
	$self->{'loop_count'} += 1;
	my $prompt = ('>' x $self->{'loop_count'}) . ' ';

	# Loop until exit command is reached
	while ($self->{'loop_count'} == 1 || 
		($line ne "exit" && $line ne "quit" 
			&& $line ne "resume" && $line ne "abort")) {
		$self->abort(0);

		# Find next line to process
		my $server = $self->var('server');
		if (! $server) {
			$line = $self->term()->readline($prompt, $self->nextcmd());
		} else {
			my @requests = sort(glob($server));
			$line = "sleep 0.1";

			# Find first file in queue
			while (@requests) {
				my $file = shift(@requests);
				if (-r $file && -f $file && ($file !~ /~$/)) {
					my $tmp = $file . '~';
					rename($file, $tmp);
					$line = "script $tmp";
					@requests = ();
				}
			} 
		}

		# Process line
		$line = "exit" if (! defined($line));
		$self->nextcmd("");
		eval { $self->do($line) };
		warn $@ if $@;
	}

	# Decrease the loop count
	$self->{'loop_count'} -= 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/mid2mspec.pl
## ------------------------------------------------------------

sub mid2mspec {
	my $self = shift;
	my $match = shift;
	
	# Initialize variables
	my $matches = $self->{'matches'};
	my $file = undef;
	my $binding = undef;
	$match = 1 if ($match < 1);

	# Convert match index to file name and index
	my $i = 0;
	foreach my $f (sort(keys(%$matches))) {
		my $m = $matches->{$f};
		if ($i + scalar(@$m) < $match) {
			# Search next file
			$i += scalar(@$m);
		} else {
			# Return found match
			$file = $f;
			$binding = $m->[$match - $i - 1];
			last;
		}
	}

	# Return file and binding
	return ($file, $binding);
} 


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/new.pl
## ------------------------------------------------------------

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = { };
    bless ($self, $class);

	# Set defaults
	$self->lexicon(undef);
	$self->var('options', {});
	$self->term(Term::ReadLine->new("Terminal"));
	$self->nextcmd("");
	$self->pslabels("msd|gloss");
	$self->fpsfile("/tmp/dtag-$$-$viewer.ps");
	$self->var('goto_context', 5);
	$self->var('loop_count', 0);
	$self->var('matches', {});
	$self->init_layout();
	$self->interactive(1);
	$self->var("tag_segment_ends", sub { $_[0] =~ /<\/[sS]>/ });
	$self->var("todo", []);
	$self->var("relsets", {});

	# Create empty graph
	$self->{'graphs'} = [DTAG::Graph->new($self)];
	$interpreter = $self;

	# Initialize graph
    return $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/nextcmd.pl
## ------------------------------------------------------------

sub nextcmd {
	my $self = shift;
	return $self->var('nextcmd', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/nice_string.pl
## ------------------------------------------------------------

sub nice_string {
       join("",
         map { $_ > 255 ?                  # if wide character...
               sprintf("\\x{%04X}", $_) :  # \x{...}
               chr($_) =~ /[[:cntrl:]]/ ?  # else if control character...
               sprintf("\\x%02X", $_) :    # \x..
               chr($_)                     # else as themselves
         } unpack("U*", $_[0]));           # unpack Unicode characters
   }

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/option.pl
## ------------------------------------------------------------

sub option {
	my $self = shift;
	my $var = shift;
	my $value = shift;
	my $options = $self->{'options'};

	# Set value
	if (defined($value) && defined($var)) {
		$options->{$var} = $value;
	}

	# Return value
	return $options->{$var};
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/print.pl
## ------------------------------------------------------------

sub print {
	my $self = shift;

	# Originating procedure
	my $facility = shift;		

	# Importance of message: error|warning|result|debug
	my $level = shift;

	# Message to be printed
	my $message = shift;

	# Print message
	print encode_utf8($message)
		if (! ($level eq "info" && $self->quiet()));
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/print_match.pl
## ------------------------------------------------------------

sub print_match {
	my $self = shift;
	my $match = shift;
	my $file = shift;
	my $binding = shift;
	my $options = shift;
	my @vars = sort(grep {substr($_, 0, 1) eq '$'} keys(%$binding));

	# Find graph index from graph ID
	if ($file =~ /^\[G[0-9]*\]$/) {
		my $index = $self->gid2index($file) + 1;
		$file = "G$index";
	}

	# Find goto position
	my $position = "1e100";
	grep {
		my $n = $binding->{$_};
		$position = $n if ($n =~ /^[0-9]+$/ && $n < $position)
	} @vars;
	$position = max(0, $position - ($self->var('goto_context') || 0));

	# Print match
	my $string = "";
	if (! $options->{'nomatch'}) {
		my $varstr = join(", ", map {
				$self->varkey($binding, $_) . $binding->{$_}
			} (@vars));
		$string .=	sprintf '%sM%-3d match at %s:%s %s' . "\n",
				(($self->{'match'} || 0) == $match ? "*" : " "),
				$match,
				$file,
				$position,
				"(" . join(", ", @vars) . ")"
					. " = (" . $varstr  . ")";
	}

	# Print key and text
	if ($binding->{'key'} && ! $options->{'nokey'}) {
		$string .= 	"      key: " . $binding->{'key'} ."\n";
	}
	if ($binding->{'text'} && ! $options->{'notext'}) {
		$string .= 	"      text: " . $binding->{'text'} ."\n";
	}

	# Return string
	return $string;
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/process_aedge_da_de.pl
## ------------------------------------------------------------

sub process_aedge_da_de {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Debug
	#print $e->string() . "\n";	

	# Check inkey and outkey
	return if (! ($e->outkey() eq $skey && $e->inkey() eq $tkey));

	# Color all non 1-1 edges
	#if (scalar(@{$e->inArray()}) > 1 || scalar(@{$e->outArray()}) > 1) {
	#	foreach my $n (@{$e->inArray()}) {
	#		my $node = $graph->node($n);
	#		$node->var('styles', 'red') if ($node);
	#	}
	#}

	# Process all 1-2 edges 
	if (scalar(@{$e->inArray()}) == 2 && scalar(@{$e->outArray()}) == 1) {
		my $out = $e->outArray()->[0];
		my $in1 = $e->inArray()->[0];
		my $in2 = $e->inArray()->[1];
		
		if ($graph->node($in1)->var($tag) =~ /^VB/
				&& ($graph->node($in2)->var($tag) =~ /^VB/
					|| $graph->node($in2)->input() =~ /ed$/)) {
			# V <--> V1 V2
			my_edge_add($graph, Edge->new($in2, $in1, 'vobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^D/
				&& $graph->node($in2)->var($tag) =~ /^N/) {
			# Ndef <--> DET N
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^N/
				&& $graph->node($in2)->var($tag) =~ /^N/) {
			# N <--> N N
			my_edge_add($graph, Edge->new($in1, $in2, 'mod'), "");
		} elsif ($graph->node($in2)->var($tag) =~ /^IN/) {
			# X <--> X P
			my_edge_add($graph, Edge->new($in2, $in1, 'pobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^IN/
				&& $graph->node($in2)->var($tag) =~ /^[ND]/) {
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} else {
			# Default
			#my_edge_add($graph, Edge->new($in2, $in1, '???'));
		}
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/process_aedge_da_en.pl
## ------------------------------------------------------------

sub process_aedge_da_en {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Debug
	#print $e->string() . "\n";	

	# Check inkey and outkey
	return if (! ($e->outkey() eq $skey && $e->inkey() eq $tkey));

	# Color all non 1-1 edges
	#if (scalar(@{$e->inArray()}) > 1 || scalar(@{$e->outArray()}) > 1) {
	#	foreach my $n (@{$e->inArray()}) {
	#		my $node = $graph->node($n);
	#		$node->var('styles', 'red') if ($node);
	#	}
	#}

	# Process all 1-2 edges 
	if (scalar(@{$e->inArray()}) == 2 && scalar(@{$e->outArray()}) == 1) {
		my $out = $e->outArray()->[0];
		my $in1 = $e->inArray()->[0];
		my $in2 = $e->inArray()->[1];
		
		if ($graph->node($in1)->var($tag) =~ /^VB/
				&& ($graph->node($in2)->var($tag) =~ /^VB/
					|| $graph->node($in2)->input() =~ /ed$/)) {
			# V <--> V1 V2
			my_edge_add($graph, Edge->new($in2, $in1, 'vobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^D/
				&& $graph->node($in2)->var($tag) =~ /^N/) {
			# Ndef <--> DET N
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^N/
				&& $graph->node($in2)->var($tag) =~ /^N/) {
			# N <--> N N
			my_edge_add($graph, Edge->new($in1, $in2, 'mod'), "");
		} elsif ($graph->node($in2)->var($tag) =~ /^IN/) {
			# X <--> X P
			my_edge_add($graph, Edge->new($in2, $in1, 'pobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^IN/
				&& $graph->node($in2)->var($tag) =~ /^[ND]/) {
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} else {
			# Default
			#my_edge_add($graph, Edge->new($in2, $in1, '???'));
		}
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/process_aedge_da_es.pl
## ------------------------------------------------------------

sub process_aedge_da_es {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Debug
	#print $e->string() . "\n";	

	# Check inkey and outkey
	return if (! ($e->outkey() eq $skey && $e->inkey() eq $tkey));

	# Color all non 1-1 edges
	#if (scalar(@{$e->inArray()}) > 1 || scalar(@{$e->outArray()}) > 1) {
	#	foreach my $n (@{$e->inArray()}) {
	#		my $node = $graph->node($n);
	#		$node->var('styles', 'red') if ($node);
	#	}
	#}

	my $source = $alignment->graph($skey);

	# Process all 1-2 edges 
	if (scalar(@{$e->inArray()}) == 2 && scalar(@{$e->outArray()}) == 1) {
		my $out = $e->outArray()->[0];
		my $in1 = $e->inArray()->[0];
		my $in2 = $e->inArray()->[1];
		
		my $etype = $e->type();
		my $outtag = $source->node($out)->var($tag);
		my $in1tag = $graph->node($in1)->var($tag);
		my $in2tag = $graph->node($in2)->var($tag);

		if ($in1tag =~ /^V.*fin/ && $in2tag =~ /^V.*inf/) {
			# V <--> V1 V2
			my_edge_add($graph, Edge->new($in2, $in1, 'vobj'), "");
		} elsif ($etype eq "s") {
			my_edge_add($graph, Edge->new($in2, $in1, 'mod'), "");
		} elsif ($in1tag =~ /^ART/ && $in2tag =~ /^NC/) {
			# Ndef <--> DET N
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} elsif ($in1tag =~ /^NC/ && $in2tag =~ /^ADJ/) {
			# NN <--> N ADJ 
			my_edge_add($graph, Edge->new($in2, $in1, 'mod'), "");
		#} elsif ($in1tag =~ /^N/ && $in2tag =~ /^N/) {
		#	# N <--> N N
		#	my_edge_add($graph, Edge->new($in1, $in2, 'mod'), "");
		} elsif ($in2tag =~ /^PREP/) {
			# X <--> X P
			my_edge_add($graph, Edge->new($in2, $in1, 'pobj'), "");
		} elsif ($in1tag =~ /^PREP/ && $in2tag =~ /^(N|Art)/) {
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
			
		} else {
			# Default
			#my_edge_add($graph, Edge->new($in2, $in1, '???'));
		}
	}

	# Process all 1-3 edges
	if (scalar(@{$e->inArray()}) == 3 && scalar(@{$e->outArray()}) == 1) {
		my $out = $e->outArray()->[0];
		my $in1 = $e->inArray()->[0];
		my $in2 = $e->inArray()->[1];
		my $in3 = $e->inArray()->[2];
		
		my $etype = $e->type();
		my $outtag = $source->node($out)->var($tag);
		my $in1tag = $graph->node($in1)->var($tag);
		my $in2tag = $graph->node($in2)->var($tag);
		my $in3tag = $graph->node($in3)->var($tag);

		if ($in1tag eq "ART" && $in2tag eq "NC" && $in3tag eq "ADJ") {
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
			my_edge_add($graph, Edge->new($in3, $in1, 'mod'), "");
		}
	}		
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/process_aedge_da_it.pl
## ------------------------------------------------------------

sub process_aedge_da_it {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Debug
	#print $e->string() . "\n";	

	# Check inkey and outkey
	return if (! ($e->outkey() eq $skey && $e->inkey() eq $tkey));

	# Color all non 1-1 edges
	#if (scalar(@{$e->inArray()}) > 1 || scalar(@{$e->outArray()}) > 1) {
	#	foreach my $n (@{$e->inArray()}) {
	#		my $node = $graph->node($n);
	#		$node->var('styles', 'red') if ($node);
	#	}
	#}

	# Process all 1-2 edges 
	if (scalar(@{$e->inArray()}) == 2 && scalar(@{$e->outArray()}) == 1) {
		my $out = $e->outArray()->[0];
		my $in1 = $e->inArray()->[0];
		my $in2 = $e->inArray()->[1];
		
		if ($graph->node($in1)->var($tag) =~ /^VB/
				&& ($graph->node($in2)->var($tag) =~ /^VB/
					|| $graph->node($in2)->input() =~ /ed$/)) {
			# V <--> V1 V2
			my_edge_add($graph, Edge->new($in2, $in1, 'vobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^D/
				&& $graph->node($in2)->var($tag) =~ /^N/) {
			# Ndef <--> DET N
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^N/
				&& $graph->node($in2)->var($tag) =~ /^N/) {
			# N <--> N N
			my_edge_add($graph, Edge->new($in1, $in2, 'mod'), "");
		} elsif ($graph->node($in2)->var($tag) =~ /^IN/) {
			# X <--> X P
			my_edge_add($graph, Edge->new($in2, $in1, 'pobj'), "");
		} elsif ($graph->node($in1)->var($tag) =~ /^IN/
				&& $graph->node($in2)->var($tag) =~ /^[ND]/) {
			my_edge_add($graph, Edge->new($in2, $in1, 'nobj'), "");
		} else {
			# Default
			#my_edge_add($graph, Edge->new($in2, $in1, '???'));
		}
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/process_edge_da_de.pl
## ------------------------------------------------------------

sub process_edge_da_de {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Find edge parameters
	my $sin = $e->in();
	my $sout = $e->out();
	my $type = $e->type();

	# Translate in and out
	my $tin = src2target($alignment, $skey, $tkey, $sin);
	my $tout = src2target($alignment, $skey, $tkey, $sout);

	# Check that in and out are non-empty
	return if (! (@$tin && @$tout));

	# head:dep = 1:1: transfer dependency unaltered
	if (scalar(@$tin) == 1 && scalar(@$tout) == 1) {
		my_edge_add($graph, Edge->new($tin->[0], $tout->[0], $type), 0);
		return;
	} 

	# find head of dependent
	my $dhead = find_head($graph, $tin);
	if ($dhead) {
		# head:dep = 1:n
		if (scalar(@$tout) == 1 && scalar(@$tin) > 0) {
			my_edge_add($graph, Edge->new($dhead, $tout->[0], $type));
			return;
		}

		# head:dep = m:n, type=subj
		if ($type eq "subj") {
			# Assign subject to first verbal head
			my $node = $graph->node($tout->[0]);
			if ($node && $node->var($tag) =~ /^V/) {
				# Create subject
				my_edge_add($graph, Edge->new($dhead, $tout->[0], $type));

				# Create fillers to other verbal objects
				foreach my $n (@$tout) {
					if ($n != $tout->[0] && $graph->node($n) &&
							$graph->node($n)->var($tag) =~ /^V/) {
						my_edge_add($graph, Edge->new($dhead, $n, "[subj]"));
					}
				}
				return;
			}
		}

		# head:dep = m:n, type=mod|pnct
		if ($type =~ /^(mod|pnct|coord|conj|rel|ref)$/) {
			my $ghead = find_head($graph, $tout);
			if ($ghead) {
				my_edge_add($graph, Edge->new($dhead, $ghead, $type));
				return;
			}
		}

		# head:dep = m:n, type=[subj]
		if ($type eq "[subj]") {
			foreach my $n (@$tout) {
				if ($graph->node($n) && $graph->node($n)->var($tag) =~ /^V/) {
					my_edge_add($graph, Edge->new($dhead, $n, "[subj]"));
				}
			}
			return;
		}

		# DEFAULT: attach to last preceding node, or
		# following node if no preceding node exists
		my $gov = -1;
		foreach my $n (@$tout) {
			$gov = max($gov, $n) if ($n < $dhead);
		}
		$gov = $tout->[0] if ($gov < 0);
		my_edge_add($graph, Edge->new($dhead, $gov, $type));
		return;
	}

	# default
	print "ignored: " . 
		join(" ", @$tin, $type, @$tout) . "\n";
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/process_edge_da_en.pl
## ------------------------------------------------------------

sub process_edge_da_en {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Find edge parameters
	my $sin = $e->in();
	my $sout = $e->out();
	my $type = $e->type();

	# Translate in and out
	my $tin = src2target($alignment, $skey, $tkey, $sin);
	my $tout = src2target($alignment, $skey, $tkey, $sout);

	# Check that in and out are non-empty
	return if (! (@$tin && @$tout));

	# head:dep = 1:1: transfer dependency unaltered
	if (scalar(@$tin) == 1 && scalar(@$tout) == 1) {
		my_edge_add($graph, Edge->new($tin->[0], $tout->[0], $type), 0);
		return;
	} 

	# find head of dependent
	my $dhead = find_head($graph, $tin);
	if ($dhead) {
		# head:dep = 1:n
		if (scalar(@$tout) == 1 && scalar(@$tin) > 0) {
			my_edge_add($graph, Edge->new($dhead, $tout->[0], $type));
			return;
		}

		# head:dep = m:n, type=subj
		if ($type eq "subj") {
			# Assign subject to first verbal head
			my $node = $graph->node($tout->[0]);
			if ($node && $node->var($tag) =~ /^V/) {
				# Create subject
				my_edge_add($graph, Edge->new($dhead, $tout->[0], $type));

				# Create fillers to other verbal objects
				foreach my $n (@$tout) {
					if ($n != $tout->[0] && $graph->node($n) &&
							$graph->node($n)->var($tag) =~ /^V/) {
						my_edge_add($graph, Edge->new($dhead, $n, "[subj]"));
					}
				}
				return;
			}
		}

		# head:dep = m:n, type=mod|pnct
		if ($type =~ /^(mod|pnct|coord|conj|rel|ref)$/) {
			my $ghead = find_head($graph, $tout);
			if ($ghead) {
				my_edge_add($graph, Edge->new($dhead, $ghead, $type));
				return;
			}
		}

		# head:dep = m:n, type=[subj]
		if ($type eq "[subj]") {
			foreach my $n (@$tout) {
				if ($graph->node($n) && $graph->node($n)->var($tag) =~ /^V/) {
					my_edge_add($graph, Edge->new($dhead, $n, "[subj]"));
				}
			}
			return;
		}

		# DEFAULT: attach to last preceding node, or
		# following node if no preceding node exists
		my $gov = -1;
		foreach my $n (@$tout) {
			$gov = max($gov, $n) if ($n < $dhead);
		}
		$gov = $tout->[0] if ($gov < 0);
		my_edge_add($graph, Edge->new($dhead, $gov, $type));
		return;
	}

	# default
	print "ignored: " . 
		join(" ", @$tin, $type, @$tout) . "\n";
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/process_edge_da_es.pl
## ------------------------------------------------------------

sub process_edge_da_es {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Find edge parameters
	my $source = $alignment->graph($skey);
	my $sin = $e->in();
	my $sout = $e->out();
	my $type = $e->type();

	# Adjust source edge for possessives!!!
	if (my @possd = grep {$_->type() eq "possd"} 
			@{$source->node($sin)->out()}) {
		print "SOURCE REPLACE: $sin<=$type=$sout with ", $possd[0]->in(), "<=$type=$sout\n";
		$sin = $possd[0]->in();
	}

	# Translate in and out
	my $tin = src2target($alignment, $skey, $tkey, $sin);
	my $tout = src2target($alignment, $skey, $tkey, $sout);

	# Check that in and out are non-empty
	return if (! (@$tin && @$tout));

	# head:dep = 1:1: transfer dependency unaltered
	if (scalar(@$tin) == 1 && scalar(@$tout) == 1) {
		my $tintag = $graph->node($tin->[0])->var('msd');
		my $touttag = $graph->node($tout->[0])->var('msd');
		my $ntype = $type;

		# Create new edge
		my_edge_add($graph, Edge->new($tin->[0], $tout->[0], $ntype), 0);
		return;
	} 

	# find head of dependent
	my $dhead = find_head($graph, $tin);

	# Go ahead...
	if ($dhead) {
		# head:dep = 1:n
		if (scalar(@$tout) == 1 && scalar(@$tin) > 0) {
			my_edge_add($graph, Edge->new($dhead, $tout->[0], $type));
			return;
		}

		# head:dep = m:n, type=subj
		if ($type eq "subj") {
			# Assign subject to first verbal head
			my $node = $graph->node($tout->[0]);
			if ($node && $node->var($tag) =~ /^V/) {
				# Create subject
				my_edge_add($graph, Edge->new($dhead, $tout->[0], $type));

				# Create fillers to other verbal objects
				foreach my $n (@$tout) {
					if ($n != $tout->[0] && $graph->node($n) &&
							$graph->node($n)->var($tag) =~ /^V/) {
						my_edge_add($graph, Edge->new($dhead, $n, "[subj]"));
					}
				}
				return;
			}
		}

		# head:dep = m:n, type=mod|pnct
		if ($type =~ /^(mod|pnct|coord|conj|rel|ref|list)$/) {
			my $ghead = find_head($graph, $tout);
			if ($ghead) {
				my_edge_add($graph, Edge->new($dhead, $ghead, $type));
				return;
			}
		}

		# head:dep = m:n, type=[subj]
		if ($type eq "[subj]") {
			foreach my $n (@$tout) {
				if ($graph->node($n) && $graph->node($n)->var($tag) =~ /^V/) {
					my_edge_add($graph, Edge->new($dhead, $n, "[subj]"));
				}
			}
			return;
		}

		# DEFAULT: attach to last preceding node, or
		# following node if no preceding node exists
		my $gov = -1;
		foreach my $n (@$tout) {
			$gov = max($gov, $n) if ($n < $dhead);
		}
		$gov = $tout->[0] if ($gov < 0);
		my_edge_add($graph, Edge->new($dhead, $gov, $type));
		return;
	}

	# default
	print "ignored: " . 
		join(" ", @$tin, $type, @$tout) . "\n";
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/process_edge_da_it.pl
## ------------------------------------------------------------

sub process_edge_da_it {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Find edge parameters
	my $sin = $e->in();
	my $sout = $e->out();
	my $type = $e->type();

	# Translate in and out
	my $tin = src2target($alignment, $skey, $tkey, $sin);
	my $tout = src2target($alignment, $skey, $tkey, $sout);

	# Check that in and out are non-empty
	return if (! (@$tin && @$tout));

	# head:dep = 1:1: transfer dependency unaltered
	if (scalar(@$tin) == 1 && scalar(@$tout) == 1) {
		my_edge_add($graph, Edge->new($tin->[0], $tout->[0], $type), 0);
		return;
	} 

	# find head of dependent
	my $dhead = find_head($graph, $tin);
	if ($dhead) {
		# head:dep = 1:n
		if (scalar(@$tout) == 1 && scalar(@$tin) > 0) {
			my_edge_add($graph, Edge->new($dhead, $tout->[0], $type));
			return;
		}

		# head:dep = m:n, type=subj
		if ($type eq "subj") {
			# Assign subject to first verbal head
			my $node = $graph->node($tout->[0]);
			if ($node && $node->var($tag) =~ /^V/) {
				# Create subject
				my_edge_add($graph, Edge->new($dhead, $tout->[0], $type));

				# Create fillers to other verbal objects
				foreach my $n (@$tout) {
					if ($n != $tout->[0] && $graph->node($n) &&
							$graph->node($n)->var($tag) =~ /^V/) {
						my_edge_add($graph, Edge->new($dhead, $n, "[subj]"));
					}
				}
				return;
			}
		}

		# head:dep = m:n, type=mod|pnct
		if ($type =~ /^(mod|pnct|coord|conj|rel|ref)$/) {
			my $ghead = find_head($graph, $tout);
			if ($ghead) {
				my_edge_add($graph, Edge->new($dhead, $ghead, $type));
				return;
			}
		}

		# head:dep = m:n, type=[subj]
		if ($type eq "[subj]") {
			foreach my $n (@$tout) {
				if ($graph->node($n) && $graph->node($n)->var($tag) =~ /^V/) {
					my_edge_add($graph, Edge->new($dhead, $n, "[subj]"));
				}
			}
			return;
		}

		# DEFAULT: attach to last preceding node, or
		# following node if no preceding node exists
		my $gov = -1;
		foreach my $n (@$tout) {
			$gov = max($gov, $n) if ($n < $dhead);
		}
		$gov = $tout->[0] if ($gov < 0);
		my_edge_add($graph, Edge->new($dhead, $gov, $type));
		return;
	}

	# default
	print "ignored: " . 
		join(" ", @$tin, $type, @$tout) . "\n";
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/pslabels.pl
## ------------------------------------------------------------

sub pslabels {
	my $self = shift;
	return $self->var('pslabels', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/query_parser.pl
## ------------------------------------------------------------

sub query_parser {
	my $self = shift;
	$query_parser = new Parse::RecDescent($query_grammar)
		if (! $query_parser);
	
	return $query_parser;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/quiet.pl
## ------------------------------------------------------------

sub quiet {
	my $self = shift;
	return $self->var('quiet', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/read_tagdiff.pl
## ------------------------------------------------------------

sub read_tagdiff {
	my $self = shift;
	my $graph = shift;
	my $diff = shift;
	my $output = [];

	sub savecmd {
		my $l = shift;
		my $c = shift;
		my $x = shift;
		my $y = shift;
		if ($c) {
			push @$l, [$c, $x, $y];
		}
	}

	sub readrange {
        my $range = shift;
        if ($range =~ /^([0-9]+)$/) {
            return ($1 - 1, $1);
        } elsif ($range =~ /^([0-9]+),([0-9]+)$/) {
            return ($1 - 1, $2);
        }
    }

	sub diffnode {
		my $s = shift;
		my $g = shift;
		my $tagline = shift;
		my $node = Node->new();
		if ($tagline =~ /^\s*<W(.*)>(.*)<\/W>\s*$/) {
			my $input = $2;
			my $varstr = $1;
			$node->input($input);
			$node->in([]);
			$node->out([]);
			my $vars = $s->varparse($g, $varstr, 0);
			foreach my $var (keys(%$vars)) {
				$node->var($var, $vars->{$var});
			}
		} else {
			print "ERROR: Cannot parse node specification:\n";
			print $tagline, "\n";
		}
		return $node;
	}

	# Read diff lines
	open(DIFF, "<$diff"); 
	my ($cmd, $a, $b);
	while (my $line = <DIFF>) {
		chomp($line);

		if ($line =~ /^[0-9]/) {
			# Command line: save old command
			savecmd($output, $cmd, $a, $b);

			# Initialize new command
			$a = [];
			$b = [];
			if ($line =~ /^([0-9]+)a([0-9,]+)$/) {
				$cmd = ["a", $1 - 1, $1 - 1, readrange($2)];	
			} elsif ($line =~ /^([0-9,]+)c([0-9,]+)$/) {
				$cmd = ["c", readrange($1), readrange($2)];
			} elsif ($line =~ /^([0-9,]+)d([0-9]+)$/) {
				$cmd = ["d", readrange($1), $2 - 1, $2 - 1];
			}
		} elsif ($line =~ /^< (.*)$/) {
			# Left line
			push @$a, diffnode($self, $graph, $1);
		} elsif ($line =~ /^> (.*)$/) {
			# Right line
			push @$b, diffnode($self, $graph, $1);
		} elsif ($line =~ /^---$/) {
		} else {
			print "ERROR: Unknown diff line:\n";
			print $line, "\n";
		}
	}
	savecmd($output, $cmd, $a, $b);
	close(DIFF);
	return $output;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/seconds2hhmmss.pl
## ------------------------------------------------------------

sub seconds2hhmmss {
	my $seconds = shift;

	return sprintf("%02i:%02i:%02i", 
		int($seconds / 3600), int($seconds / 60) % 60, int($seconds) % 60);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/signal_handler.pl
## ------------------------------------------------------------

sub signal_handler {
	my $self = shift;
	my $signame = shift;

	# Set abort flag
	$self->abort(1);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/strip_relation.pl
## ------------------------------------------------------------

sub strip_relation {
	my $type = shift;
    $type =~ s/^[:;+]//g;
	$type =~ s/^[¹²³^]+//g;
	$type =~ s/^\¤//g;
	$type =~ s/[¹²³^]+$//g;
	$type =~ s/\#$//g;
	$type =~ s/^@//g;
	$type =~ s/\/.*$//g;
	$type =~ s/\*//g;
	$type =~ s/[()]//g;
	$type =~ s/\/ATTR[0-9]+//g;
	return $type;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/term.pl
## ------------------------------------------------------------

sub term {
	my $self = shift;
	return $self->var('term', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/unsafe.pl
## ------------------------------------------------------------

sub unsafe {
	my $self = shift;
	return $self->var('unsafe', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/var.pl
## ------------------------------------------------------------

sub var {
	my $self = shift;
	my $var = shift;

	# Set variable, if value given
	$self->{$var} = shift if (@_);

	# Return variable
	return $self->{$var};
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/varkey.pl
## ------------------------------------------------------------

sub varkey {
	my ($self, $bindings, $var) = @_;
	my $key = $bindings->{'vars'}{defined($var) ? $var : ""};
	return defined($key) ? $key : "";
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/varparse.pl
## ------------------------------------------------------------

sub varparse {
	my $self = shift;
	my $graph = shift;
	my $varstr = shift() . " ";
	my $varchk = shift || 0;
	my $hash = { };
	my ($var, $val);

	# Process variable specification
	while ($varstr) {
		# Read first variable-value pair
		if ($varstr =~ s/^\s*([^=\s]+)="`([^`]*)`"\s+//) {
			# Quoted-backquoted value
			($var, $val) = ($1, eval($2));
		} elsif ($varstr =~ s/^\s*([^=\s]+)=`([^`]*)`\s+//) {
			# Back-quoted value
			($var, $val) = ($1, eval($2));
		} elsif ($varstr =~ s/^\s*([^=\s]+)=(&22;)+(\S+?)(&22;)+\s+//) {
			# Quoted value
			($var, $val) = ($1, "$3");
		} elsif ($varstr =~ s/^\s*([^=\s]+)="([^"]*)"\s+//) {
			# Quoted value
			($var, $val) = ($1, "$2");
		} elsif ($varstr =~ s/^\s*([^=\s]+)=([^"]\S*)\s+//) {
			# Non-quoted value
			($var, $val) = ($1, $2);
		} elsif ($varstr =~ s/^\s*([^=\s]+)//) {
			# Variable name
			($var, $val) = ($1, undef);
		} elsif ($varstr =~ s/^\s+//) {
			# Blanks
			($var, $val) = (undef, undef);
		} else {
			# Syntax error: delete until next space
			$varstr =~ s/^\s*(\S+)\s*//;
			error($graph->size() .
				": not a variable-value pair: $1");
			($var, $val) = (undef, undef);
		}

		# Check that variable-value pair is defined
		if (defined($var)) {
			my $cvar = $varchk ? $graph->abbr2var($var) : $var;
			$cvar = 'input' if ($var eq 'input');
			if (defined($cvar)) {
				$hash->{$cvar} = $val;
			} else {
				error($graph->size() 
					. ": non-existent variable name: <$var>");
			}
		}
	}	

	# Return hash
	return $hash;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/warning.pl
## ------------------------------------------------------------

sub warning {
	print "\aWARNING! " . join("", @_) . "\n";
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/xml2edge.pl
## ------------------------------------------------------------

sub xml2edge {
	my $etypes = shift;
	my $out = shift;

	# Process feature-value pairs
	my ($in, $label);
	while (@_) {
		my $feature = shift;
		my $value = shift;
		
		# Ignore undefined feature value pairs
		next() if (! defined($feature) || ! defined($value));

		# Save feature-value pair, if defined
		if ($feature eq 'idref') {
			# Incoming node id
			$in = $value;
		} elsif ($feature eq 'label') {
			# Edge label
			$label = $value;
		}
	}

	# Create edge
	return Edge->new($in, $out, $label);
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/xml2node.pl
## ------------------------------------------------------------

sub xml2node {
	# Create node
	my $vars = shift;
	my $type = shift;
	my $tag = shift;
	my $node = Node->new();

	# Compute string representation of XML tag and set feature-value pairs
	my @strings = ();
	my $word = "";
	while (@_) {
		my $feature = shift;
		my $value = shift;
		
		# Save feature-value pair, if defined
		if (defined($feature) && $feature eq 'word') {
			# Word features are stored as input
			$word = defined($value) ? $value : "";
		} elsif (defined($feature) && defined($value)) {
			# Other features are stored as variables 
			$node->var($feature, $value);
			push @strings, "$feature=\"$value\"";
			$vars->{$feature} = 1;
		}
	}

	# Set string of node and comment status
	if ($type == $TIGER_COMMENT) {
		$node->input(join(" ", "<$tag",  @strings) . ">");
		$node->comment(1);
	} elsif ($type == $TIGER_T) {
		$node->input($word);
	} elsif ($type == $TIGER_NT) {
		$node->input("");
	}

	# Return node
	return $node;
}

## ------------------------------------------------------------
##  start auto-insert from directory: .svn
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: tmp
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: tmp
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: .svn
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: FindOps
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindADJ.pl
## ------------------------------------------------------------

package FindADJ;
@FindADJ::ISA = qw(FindOp);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
	my $node1 = shift;
	my $node2 = shift;
	my $range = shift || [1,1];
	my $dir = shift || 1;

	# Find dmin and dmax
	my $dmin = 1e100;
	my $dmax = 0;
	foreach my $r (@$range) {
		$dmin = $r->[0] if ($dmin > $r->[0]);
		$dmax = $r->[1] if ($dmax < $r->[1]);
	}

	# Create object
    my $self = {'args' => [$node1, $node2, $range, $dir, $dmin, $dmax]};
    bless($self, $class);
    return $self;
}

sub next {
    my $self = shift;
    my $graph = shift;
    my $bindings = shift;
    my $bind = shift;
    my $U = pop;

    # Decline answer if constraint is negated
    return undef if ($self->{'neg'});

    # Constraint is unnegated, and there is exactly one unbound
    # variable U and bound variable B.
	my $Barg = ($U eq $self->{'args'}[0]) ? 1 : 0;
    my $B = $self->{'args'}[$Barg];
    my $Bval = $self->varbind($bindings, $bind, $B);
	my $dmax = $self->{'args'}[5];

    if ($bind->{$U} <= $Bval - $dmax) {
        $bind->{$U} = ($Bval - $dmax < 0 ? 0 : $Bval - $dmax);
        return 1;
    } elsif ($bind->{$U} <= $Bval + $dmax) {
		return 1;
	} else {
        return 0;
    }
}

sub vars {
	return [0,1];
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	my $n0 = $self->varbind($bindings, $bind, $self->{'args'}[0]);
	my $n1 = $self->varbind($bindings, $bind, $self->{'args'}[1]);
	my $range = $self->{'args'}[2];

	my $dist = ($n1 - $n0) * ($self->{'args'}[3] || 1);
	foreach my $r (@$range) {
		my ($dmin, $dmax) = @$r;
		return 1 if ($dist >= $dmin && $dist <= $dmax);
	}
	return 0;
}


sub pprint {
	my $self = shift;
	my ($n0, $n1, $range, $dir) = @{$self->{'args'}};
	my $rangestr = join(",",
		map {$_->[0] == $_->[1] ? $_->[0] : $_->[0] . ".." . $_->[1]}
			@$range);
	$rangestr = "" if ($rangestr eq "1");
	return "(" . $n0
		. ($dir > 0 
			? " <" . $rangestr . "< "
			: " >" . $rangestr . "> ")
		. $n1 . ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindAND.pl
## ------------------------------------------------------------

package FindAND;
@FindAND::ISA = qw(FindOp);

sub negate {
	my $self = shift;
	return FindOR->new(map {$_->negate()} @{$self->{'args'}});
}

sub dnf {
	my $self = shift;

	# Compute DNFs of all arguments
	my @dnfs = map {$_->dnf()} @{$self->{'args'}};

	# Compute collective DNF by reducing AND(OR(X_i), Y1, ..., YN)
	# to OR_i DNF(AND(X_i,Y1,...,YN))
	my $dnf = shift(@dnfs)->{'args'};
	while(@dnfs) {
		# Find conjunctions in Ith DNF
		my $dnfI = shift(@dnfs)->{'args'};

		# Save all possible combinations of conjunctions in $dnf and
		# $dnfI in $dnfnew
		my $dnfnew = [];
		foreach my $and1 (@$dnf) {
			foreach my $andI (@$dnfI) {
				my @args = ();
				push @args, @{$and1->{'args'}};
				push @args, @{$andI->{'args'}};
				push @$dnfnew, FindAND->new(@args);
			}
		}
			
		# Replace $dnf by $dnfnew, and repeat the procedure
		$dnf = $dnfnew;
	}	

	# Return resulting DNF
	return FindOR->new(@$dnf);
}

sub solve {
	my $self = shift;
	my $graph = shift;
	my $maxsols = shift || 0;
	my $bindings = shift || {};
	my $solutions = shift || [];
	$graph->bindgraph($bindings);

	# Find list of all active constraints, ie, constraints with
	# uninstantiated variables
	my $args = $self->{'args'};
	my $active = {};
	my $asols = {};
	for (my $i = 0; $i < scalar(@$args); ++$i) {
		# Initialize search for condition
		my $cond = $args->[$i];
		$cond->find_init($bindings);

		if (keys(%{$cond->{'bind'}})) {
			# Find constraints with unbound variables
			$active->{$i} = 0;
			$asols->{$i} = [];
		} else {
			# Return if bindings have been falsified
			my $true = $cond->match($graph, $bindings, {});
			$true = $cond->{'neg'} ? (! $true) : $true;
			if (! $true) {
				# print "UNKNOWN ERROR!\n";
				return $solutions 
			}
		}
	}

	# Return if there are no active constraints
	if (! %$active) {
		# Add solution, if new, and return
		push @$solutions, $bindings;
		return $solutions;
	}

	# Find minimal active constraint, ie, active constraint with
	# minimal number of solutions
	my $incomplete = 1;
	my $minsols = 0;
	my $min;
	while ($incomplete) {
		# Find currently minimal active constraints
		my @mins = grep {$active->{$_} == $minsols} keys(%$active);
		$min = $mins[0];

		# Find new solution for currently minimal constraint
		my $newsol = $args->[$min]->find_next($graph, $bindings);
		if (! defined($newsol)) {
			$incomplete = 0;
		} else {
			# Save new partial solution
			push @{$asols->{$min}}, $newsol;

			# Update solution count and find new minimal count
			$active->{$min} += 1;
			++$minsols
				if (! grep {$active->{$_} == $minsols} keys(%$active));
		}
	}

	# Active constraint $min is minimal; solutions in $asols->{$min}
	foreach my $bind (@{$asols->{$min}}) {
		if (scalar(@$solutions) < $maxsols || ! $maxsols) {
			# Copy bindings array, and set new variable bindings
			my $newbindings = {};
			map {$newbindings->{$_} = $bindings->{$_}} (keys(%$bindings));
			map {$newbindings->{$_} = $bind->{$_}} (keys(%$bind));

			# Call solve recursively on new bindings
			$self->solve($graph, $maxsols, $newbindings, $solutions);
		}
	}

	# Return solutions
	return $solutions;
}

sub unbound {
	my $self = shift;
	my $unbound = shift;

	# For each argument, mark all unbound variables in hash $unbound
	foreach my $and (@{$self->{'args'}}) {
		$and->unbound($unbound);
	}

	# Return
	return $unbound;
}

sub _pprint {
    my $self = shift;
    my $args = $self->{'args'};
    if (scalar(@$args) > 1) {
        return "(" . join($self->utf8print() ? " ∧ " : " & ",
            map {$_->pprint()} @$args) . ")";
    } else {
        return $args->[0]->pprint();
    }
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindAction.pl
## ------------------------------------------------------------

package FindAction;

use overload
    '""' => \& print;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
    my $self = {'args' => [@_]};
    bless($self, $class);
    return $self;
}

sub ask {
	return 1;
}

sub close {
}

sub print {
	my $self = shift;
	return "" . $self;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindActionDTAG.pl
## ------------------------------------------------------------

package FindActionDTAG;
@FindActionDTAG::ISA = qw(FindAction);

sub commands {
	my ($self, $graph, $binding) = @_;

   	# Replace variables with bindings
	my $cmds = [];
	foreach my $oplist (@{$self->{'args'}}) {
		my $cmd = "";
		foreach my $op (@$oplist) {
			$cmd .= $op->value($graph, $binding);
		}
		push @$cmds, $cmd;
	}
	return $cmds;
}

sub string {
	my ($self, $graph, $binding) = @_;
	return join("; ", @{$self->commands($graph, $binding)});
}

sub do {
	my ($self, $graph, $binding, $interpreter) = @_;
	foreach my $cmd (@{$self->commands($graph, $binding)}) {
		$interpreter->do($cmd);
	}
}

sub print {
	my $self = shift;
	my @cmds = ();
	foreach my $cmd (@{$self->{'args'}}) {
		push @cmds, join(",", @$cmd);
	}
	return join("§", @cmds);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindActionTable.pl
## ------------------------------------------------------------

package FindActionTable;
@FindActionTable::ISA = qw(FindAction);

sub do {
	my $self = shift;
	my $binding = shift;
	my $interpreter = shift;
	my $ask = shift;

   	# Replace variables with bindings
	foreach my $op (@{$self->{'args'}}) {	
		foreach my $var (keys(%$binding)) {
			my $val = $binding->{$var};
			$var = '\\' . $var;
			$op =~ s/$var/$val/g;
		}
		print "    Operation: $op\n" if ($ask);
		$interpreter->do($op);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindAlign.pl
## ------------------------------------------------------------

package FindAlign;
@FindAlign::ISA = qw(FindOp);

sub _pprint {
	my $self = shift;
	my $outvars = $self->{'args'}[0];
	my $invars = $self->{'args'}[1];
	my $relpattern = $self->{'args'}[2];
	return "@" 
		. (defined($relpattern) ? $relpattern->pprint() : "")
		. "(" 
		. join(",", @$outvars)
		. ";"
		. join(",", @$invars)
		. ")";
}

sub unbound {
    # Return all unbound variables
    my $self = shift;
    my $unbound = shift;
    
	# Mark all unbound variables in hash $unbound
	my $args = $self->{'args'};
    map {$unbound->{$_} = 1} 
		(@{$args->[0]}, @{$args->[1]});

    # Return
    return $unbound;
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	#print "match: " 
	#	. join(" ", map {$_ . "=" . $bindings->{$_}} sort(keys(%$bindings))) 
	#	. " / "
	#	. join(" ", map {$_ . "=" . $bind->{$_}} sort(keys(%$bind))) . "\n";

	# Out- and in-variables
	my $outvars = [@{$self->{'args'}[0]}];
	my $invars = [@{$self->{'args'}[1]}];
	my $outfullmatch = $outvars->[0] eq "!" ? shift(@$outvars) : 0;
	my $infullmatch = $invars->[0] eq "!" ? shift(@$invars) : 0;

	# Find graphs and keys for nodes
	my $outgraph = $self->keygraph($graph, $bindings, @$outvars);
	my $ingraph = $self->keygraph($graph, $bindings, @$invars);
	my $outkey = $self->varkey($bindings, $outvars->[0]);
	my $inkey = $self->varkey($bindings, $invars->[0]);
	
	# Find potential edges (based on first out-node and outkey), 
	# and filter all potential edges
	my $out1 = $self->varbind($bindings, $bind, $outvars->[0]);
	my $edges = [];
	EDGE : foreach my $e (@{$graph->node_edges($outkey, $out1) || []}) {
		# Check edge
		my $edge = $graph->edge($e);
		next EDGE if (! defined($edge));

		# Check in- and outkey of edge
		next EDGE if ($edge->inkey() ne $inkey
			|| $edge->outkey() ne $outkey);

		# Check number of in- and out-nodes on the edge
		next EDGE if (($outfullmatch 
				&& scalar(@{$edge->outArray()}) != scalar(@$outvars)) ||
			($infullmatch 
				&& scalar(@{$edge->inArray()}) != scalar(@$invars)));

		# Check each outnode is unique and valid on edge
		my $counts = {};
		map {$counts->{$_} = 0} @{$edge->outArray()};
		foreach my $outvar (@$outvars) {
			# Skip if not on outedge, or if outnode is non-unique
			my $out = $self->varbind($bindings, $bind, $outvar);
			next EDGE if (! defined($counts->{$out}));
			next EDGE if ($counts->{$out}++);
		}

		# Check each innode is unique and valid on edge
		$counts = {};
		map {$counts->{$_} = 0} @{$edge->inArray()};
		foreach my $invar (@$invars) {
			# Skip if not on inedge, or if innode is non-unique
			my $in = $self->varbind($bindings, $bind, $invar);
			next EDGE if (! defined($counts->{$in}));
			next EDGE if ($counts->{$in}++);
		}

		# Edge matches, so constraint is satisfied
		push @$edges, $edge;
	}

	# Check that there is an edge whose type matches given relation condition
	my $relpattern = $self->{'args'}[2];
	foreach my $edge (@$edges) {
		return 1 if ((! defined($relpattern)) 
			|| $relpattern->match($graph, $edge->type()));
	}

	# Otherwise return 0
	return 0;
}

sub next { 
    my $self = shift;
    my $graph = shift;
    my $bindings = shift;
    my $bind = shift;
    my @vars = @_;

	#print "vars: " . join(" ", @vars) . "\n";
	# Exit if constraint is negated
	return undef if ($self->{'neg'});
	
	# Out- and in-variables
	my $outvars = [@{$self->{'args'}[0]}];
	my $invars = [@{$self->{'args'}[1]}];

	# Find graphs and keys for nodes
	my $outgraph = $self->keygraph($graph, $bindings, @$outvars);
	my $ingraph = $self->keygraph($graph, $bindings, @$invars);
	my $outkey = $self->varkey($bindings, $outvars->[0]);
	my $inkey = $self->varkey($bindings, $invars->[0]);

	# Convert invar and outvar lists to hash tables
	my $invarhash = {};
	my $outvarhash = {};
	map {$outvarhash->{$_} = 1} (@$outvars);
	map {$invarhash->{$_} = 1} (@$invars);

	#

	# Find earliest variable in @vars on edge, remove all variables
	# from @vars that are not after this variable
	my ($var1) = grep {($outvarhash->{$_} || $invarhash->{$_})
			&& ! defined($bind->{$_})}
		sort(keys(%$bindings));
	my $key1 = $var1 ? $self->varkey($bindings, $var1) : undef;
	while (@vars && ! $var1) {
		my $v = shift(@vars);
		($var1, $key1) = ($v, $outkey) if ($outvarhash->{$v});
		($var1, $key1) = ($v, $inkey) if ($invarhash->{$v});
	}

	# Find value of earliest variable in binding
	my $val1 = $self->varbind($bindings, $bind, $var1);

	# Find alignment edges containing the node
	my $edges = $graph->node_edges($key1, $val1);
	if (! @$edges) {
		#print "return: $var1/" . join(",", @vars) . " " . join(" ", map {$_ . "=" . $bind->{$_}} keys(%$bind)) . "\n";
		$bind->{$var1}++;
		foreach my $v (@vars) {
			$bind->{$v} = 0;
		}
		return 1;
	}

	# Record all possible in- and out-nodes on alignment edges
	# connected to $var1
	my $outvals = {};
	my $invals = $outkey eq $inkey ? $outvals : {};
	foreach my $e (@$edges) {
		# Get alignment edge
		my $edge = $graph->edge($e);
		next if (! defined($edge));

		# Record node ids on alignment edge
		map {$outvals->{$_} = 1} @{$edge->outArray()};
		map {$invals->{$_} = 1} @{$edge->inArray()};
	}

	# Sort values in $invals and $outvals
	my @insort = sort(keys(%$invals));
	my @outsort = sort(keys(%$outvals));

	# Update variables in @vars
	foreach my $var (@vars) {
		my $val = $bind->{$var};
		$bind->{$var} = nextInArray($val, @insort)
			if ($invarhash->{$var});
		$bind->{$var} = nextInArray($val, @outsort, 1e100)
			if ($outvarhash->{$var});
	}

	
	# Return
	return 1;
}

sub nextInArray {
	my $value = shift;
	foreach my $v (@_) {
		return $v if ($v >= $value);
	}
	return 1e100;
}





## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindEXIST.pl
## ------------------------------------------------------------

package FindEXIST;
@FindEXIST::ISA = qw(FindOp);

#sub new {
#}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Find variable and condition
	my $var = $self->varname();
	my $varkey = $self->varkey();
	my $keygraph = $graph->graph($varkey);
	my $cond = $self->{'args'}[1];
	my $oldval = $bind->{$var};
	my $neg = $self->{'neg'} ? 1 : 0;

	# Fix bindings in $bind and $bindings
	my $newbindings = {};
	my $newvarbindings = {};
	my $varbindings = $bindings->{'vars'};
	map {$newbindings->{$_} = $bindings->{$_}} keys(%$bindings);
	map {$newbindings->{$_} = $bind->{$_}} keys(%$bind);
	map {$newvarbindings->{$_} = $varbindings->{$_}}
		keys(%$varbindings);
	$newbindings->{'vars'} = $newvarbindings;
	delete $newbindings->{$var};

	# Find all solutions to $cond with $newbindings
	my $solutions = $cond->solve($keygraph, 0, $newbindings); 

	# Check number of solutions in $solutions
	return @$solutions;
}

sub unbound {
	my $self = shift;
	my $unbound = shift;

	# Find unbound variables in argument
	$self->{'args'}[1]->unbound($unbound);

	# Remove variable from 
	delete $unbound->{$self->varname()};

	# Return unbound variables
	return $unbound;
}

sub dnf {
	my $self = shift;
	my $var = $self->varname();
	my $neg = $self->{'neg'};

	# Return self if $self->{'dnf'} is set
	return FindOR->new(FindAND->new($self)) if ($self->{'dnf'});

	# Compute DNF of argument: FindOR(FindAND(...), ...)
	my $argdnf = $self->{'args'}[1]->dnf();

	# Process each disjunct
	my $new = $neg ? FindAND->new() : FindOR->new();
	foreach my $or (@{$argdnf->{'args'}}) {
		# Process each conjunct
		my @inner = ();
		my @outer = ();
		foreach my $and (@{$or->{'args'}}) {
			if (grep {$_ eq $var} keys(%{$and->unbound({})})) {
				push @inner, $and;
			} else {
				push @outer, ($neg ? $and->negate() : $and);
			}
		}

		# Resulting conjunct
		my $exist = FindEXIST->new([$var, $self->varkey()], 
			FindAND->new(@inner));
		$exist->{'dnf'} = 1;
		if ($neg) {
			# Operator: not exists
			$exist->{'neg'} = 1;
			push @{$new->{'args'}}, FindOR->new(@outer, $exist);
		} else {
			# Operator: exists
			push @{$new->{'args'}}, FindAND->new(@outer, $exist);
		}
	}

	# Return DNF of $new
	return $neg ? $new->dnf() : $new;
}

sub varname {
	my $self = shift;
	my $var = $self->{'args'}[0];
	return UNIVERSAL::isa($var, "ARRAY")
		? $var->[0] : $var;
}

sub varkey {
	my $self = shift;
	my $var = $self->{'args'}[0];
	return UNIVERSAL::isa($var, "ARRAY")
		? $var->[1] : "";
}

sub _pprint {
	my $self = shift;
	my $var = $self->varname();
	my $varkey = $self->varkey();
	my $arg = $self->{'args'}[1];
	return ($self->utf8print() ? "∃" : "EXIST") 
		. ($varkey ne "" ? $var . "@" . $varkey : $var)
		. $arg->pprint();
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindEdge.pl
## ------------------------------------------------------------

package FindEdge;
@FindEdge::ISA = qw(FindOp);

sub vars {
	return [0,1];
}

sub _pprint {
	my $self = shift;
	my $var1 = $self->{'args'}[0];
	my $var2 = $self->{'args'}[1];
	my $relpattern = $self->{'args'}[2];
	return "(" . $var1 . " " . $relpattern->pprint() . " " . $var2 .  ")";
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;
	my $var1 = $self->{'args'}[0];
	my $var2 = $self->{'args'}[1];
	my $keygraph = $self->keygraph($graph, $bindings, $var1, $var2);
	
	# Nodes
	my $in = $self->varbind($bindings, $bind, $var1);
	my $out = $self->varbind($bindings, $bind, $var2);
	my $relpattern = $self->{'args'}[2];

	# Check whether there exists an edge from node $in to $out with
	# type $etype
	my $node = $keygraph->node($in);
	return 0 if (! $node);
	return 1 
		if (grep {$_->out() == $out 
			&& $relpattern->match($keygraph, $_->type())} (@{$node->in()}));
	return 0;
}

sub next { 
    my $self = shift;
    my $graph = shift;
    my $bindings = shift;
    my $bind = shift;
    my $var = pop;

	my $var1 = $self->{'args'}[0];
	my $var2 = $self->{'args'}[1];
	my $keygraph = $self->keygraph($graph, $bindings, $var1, $var2);

	# Exit if constraint is negated
	return undef if ($self->{'neg'});

	# Find suggested in and out node
	my $in = $self->varbind($bindings, $bind, $var1);
	my $out = $self->varbind($bindings, $bind, $var2);
	
	# Determine unbound variable
	my $relpattern = $self->{'args'}[2];
	if ($var eq $var2) {
		# Determine out-node from in-node: find in-node
		my $node = $keygraph->node($in);
		return 0 if (! $node);

		# Find matching edges
		my @edges = sort {$a->out() <=> $b->out()} 
			(grep {$relpattern->match($keygraph, $_->type()) 
				&& $_->out() >= $out}  
				@{$node->in()});

		# Set $var, if there is a match
		if (@edges) {
			$bind->{$var2} = $edges[0]->out();
			return 1;
		} else {
			return 0;
		}
	} elsif ($var eq $var1) {
		# Determine in-node from out-node: find out-node
		my $node = $keygraph->node($out);
		return 0 if (! $node);

		# Find matching edges
		my @edges = sort {$a->in() <=> $b->in()} 
			(grep {$relpattern->match($keygraph, $_->type()) 
					&& $_->in() >= $in}  
				@{$node->out()});

		# Set $var, if there is a match
		if (@edges) {
			$bind->{$var1} = $edges[0]->in();
			return 1;
		} else {
			return 0;
		}
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindMatch.pl
## ------------------------------------------------------------

package FindMatch;
@FindMatch::ISA = qw(FindProc);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
    my $self = {'args' => [@_]};
    bless($self, $class);
    return $self;
}




## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindMatchStringEQ.pl
## ------------------------------------------------------------

package FindMatchStringEQ;
@FindMatchStringEQ::ISA = qw(FindMatch);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $pattern = $self->{'args'}[0];
	return $string eq $self->{'args'}[0];
}

sub pprint {
	my $self = shift;
	return '"' . $self->{'args'}[0] . '"';
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindMatchStringIsa.pl
## ------------------------------------------------------------

package FindMatchStringIsa;
@FindMatchStringIsa::ISA = qw(FindMatch);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $typespec = $self->{'args'}[0];
	my $relset = $graph->relset($self->{'args'}[1]);
	return $typespec->match($graph, DTAG::Interpreter::strip_relation($string), $relset);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my ($type, $relset) = @$args;
	return "isa(" . $type . 
		($relset ? ", $relset" : "") . ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindMatchStringRegExp.pl
## ------------------------------------------------------------

package FindMatchStringRegExp;
@FindMatchStringRegExp::ISA = qw(FindMatch);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $regexp = $self->{'args'}[0];
	return 0 if (! defined($regexp));
	return eval("\$string =~ $regexp")
}

sub pprint {
	my $self = shift;
	return $self->{'args'}[0];
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindNOT.pl
## ------------------------------------------------------------

package FindNOT;
@FindNOT::ISA = qw(FindOp);

sub negate {
	# Negate NOT(X) by returning X
	my $self = shift;
	return $self->{'args'}[0];
}

sub dnf {
	my $self = shift;
	my $arg = $self->{'args'}[0];

	# Reduce argument by propagating negation downwards to terminal operators
	my $reduced = $arg->negate();

	# Return DNF for reduced argument
	return $reduced->dnf();
}

sub unbound {
    my $self = shift;
    my $unbound = shift;

    # For each argument, mark all unbound variables in hash $unbound
    foreach my $and (@{$self->{'args'}}) {
        $and->unbound($unbound);
    }

    # Return
    return $unbound;
}

sub _pprint {
    my $self = shift;
    my $args = $self->{'args'};
       return ($self->utf8print() ? "¬" : "!" ) . $args->[0]->pprint();
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindNumberEQ.pl
## ------------------------------------------------------------

package FindNumberEQ;
@FindNumberEQ::ISA = qw(FindOp);

use overload
    '""' => \& print;

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$self->{'args'}[0]->unbound($unbound);
	$self->{'args'}[1]->unbound($unbound);
	return $unbound;
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift || {};

	my $val1 = $self->{'args'}[0]->nvalue($graph, $bindings, $bind);
	my $val2 = $self->{'args'}[1]->nvalue($graph, $bindings, $bind);
	return defined($val1) && defined($val2) && ($val1 == $val2);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return "(" . 
		($self->utf8print() 
			? $args->[0] . ($self->{'neg'} ? " ≠ " : " = ") . $args->[1]
			: $args->[0] . ($self->{'neg'} ? " != " : " == ") . $args->[1])
		. ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindNumberGT.pl
## ------------------------------------------------------------

package FindNumberGT;
@FindNumberGT::ISA = qw(FindOp);

use overload
    '""' => \& pprint;

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$self->{'args'}[0]->unbound($unbound);
	$self->{'args'}[1]->unbound($unbound);
	return $unbound;
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift || {};

	my $val1 = $self->{'args'}[0]->nvalue($graph, $bindings, $bind);
	my $val2 = $self->{'args'}[1]->nvalue($graph, $bindings, $bind);
	return defined($val1) && defined($val2) && ($val1 > $val2);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return "(" . ($self->utf8print() 
		? $args->[0]->pprint() . ($self->{'neg'} ? " ≤ " : " > ") . $args->[1]
		: $args->[0]->pprint() . ($self->{'neg'} ? " <= " : " > ") . $args->[1])
		. ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindNumberLT.pl
## ------------------------------------------------------------

package FindNumberLT;
@FindNumberLT::ISA = qw(FindOp);

use overload
    '""' => \& pprint;

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$self->{'args'}[0]->unbound($unbound);
	$self->{'args'}[1]->unbound($unbound);
	return $unbound;
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift || {};

	my $arg0 = $self->{'args'}[0];
	my $val1 = $arg0->nvalue($graph, $bindings, $bind);
	my $val2 = $self->{'args'}[1]->nvalue($graph, $bindings, $bind);
    #print "self=" . DTAG::Interpreter::dumper($self) . "\n";
    #print "arg0=" . DTAG::Interpreter::dumper($arg0) . "\n";
    #print "val1=" . DTAG::Interpreter::dumper($val1) . "\n";
    #print "val2=" . DTAG::Interpreter::dumper($val2) . "\n";
	#print "$val1 < $val2\n";

	return defined($val1) && defined($val2) && ($val1 < $val2);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return "(" . ($self->utf8print() 
		? $args->[0]->pprint() . ($self->{'neg'} ? " ≥ " : " < ") . $args->[1]
		: $args->[0]->pprint() . ($self->{'neg'} ? " >= " : " < ") . $args->[1])
		. ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindNumberValue.pl
## ------------------------------------------------------------

package FindNumberValue;
@FindNumberValue::ISA = qw(FindValue);

use overload
    '""' => \& pprint;
	    
sub unbound {
	my $self = shift;
	my $unbound = shift;
	return $unbound;
}

sub nvalue {
	my $self = shift;
	return $self->{'args'}[0];	
}

sub value {
	my ($self, $graph, $bindings, $bind) = @_;
	return $self->nvalue($graph, $bindings, $bind);
}

sub pprint {
	my $self = shift;
	return $self->{'args'}[0];
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindNumberValueNode.pl
## ------------------------------------------------------------

package FindNumberValueNode;
@FindNumberValueNode::ISA = qw(FindNumberValue);

use overload
    '""' => \& pprint;

sub vars {
	return [0];
}

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$unbound->{$self->{'args'}[0]} = 1;
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my $node = $args->[0];
	return $self->{'args'}[0];
}

sub nvalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Variables
	my $nodevar = $self->{'args'}[0];
	my $value = $self->varbind($bindings, $bind, $nodevar);

	#print "  self=" . DTAG::Interpreter::dumper($self) . "\n";
	#print "  bindings=" . DTAG::Interpreter::dumper($bindings) . "\n";
	#print "  bind=" . DTAG::Interpreter::dumper($bind) . "\n";
	#print "  nodevar=" . DTAG::Interpreter::dumper($nodevar) . "\n";
	#print "  value=" . DTAG::Interpreter::dumper($value) . "\n";
	return defined($value) ? $value : -1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindNumberValueNodeFeature.pl
## ------------------------------------------------------------

package FindNumberValueNodeFeature;
@FindNumberValueNodeFeature::ISA = qw(FindNumberValue);

sub vars {
	return [0];
}

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$unbound->{$self->{'args'}[0]} = 1;
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my $node = $args->[0];
	my $feat = $args->[1];
	return $self->{'args'}[0] . "[" . $feat . "]";
}

sub nvalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

   	# Variables
	my $nodevar = $self->{'args'}[0];
	my $feat = $self->{'args'}[1];

 	# Find key graph
    my $keygraph = $self->keygraph($graph, $bindings, $nodevar);
    return undef if (! defined($keygraph));

    # Find node id and node
    my $nodeid = $nodevar->nvalue($graph, $bindings, $bind);
    return undef if (! defined($nodeid));

    # Find node
    my $node = $keygraph->node($nodeid);
    return undef if (! defined($node));
	print "keygraph=$keygraph node=$node\n";

    # Find value
    my $value = defined($feat)
        ? $node->var($feat)
        : $node->input();
	$value = "" if (! defined($value));


	# Check for valid number
	if ($value =~ /^-?\d+\.?\d*$/) {
		return $value;
	} else {
		DTAG::Interpreter::warning("non-number in $nodeid" . "[$feat]: using 0 instead of " . ($value || "undef"));
		return 0;
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindNumberValueQuery.pl
## ------------------------------------------------------------

package FindNumberValueQuery;
@FindNumberValueQuery::ISA = qw(FindNumberValue);

use overload
    '""' => \& pprint;

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$self->{'args'}[0]->unbound($unbound);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my $node = $args->[0];
	return "is(" . $self->{'args'}[0]->pprint() . ")";
}

sub nvalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	my $true = $self->{'args'}[0]->match($graph, $bindings, $bind);
	return $true ? 1 : 0;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindOR.pl
## ------------------------------------------------------------

package FindOR;
@FindOR::ISA = qw(FindOp);

sub negate {
	my $self = shift;
	return FindAND->new(map {$_->negate()} @{$self->{'args'}});
}

sub dnf {
	my $self = shift;

	# Find DNF of arguments
	my @dnfs = map {$_->dnf()} @{$self->{'args'}};

	# Reduce DNFs to one big DNF
	my @ands = ();
	foreach my $dnf (@dnfs) {
		push @ands, @{$dnf->{'args'}};
	}

	# Return DNF of entire structure
	return FindOR->new(@ands);
}

sub unbound {
	my $self = shift;
	my $unbound = shift;

	# For each argument, mark all unbound variables in hash $unbound
	foreach my $and (@{$self->{'args'}}) {
		$and->unbound($unbound);
	}

	# Return
	return $unbound;
}

sub _pprint {
	my $self = shift;
	my $args = $self->{'args'};
	if (scalar(@$args) > 1) {
		return "(" . join($self->utf8print() ? " ∨ " : " | ",
        	map {$_->pprint()} @$args) . ")";
	} else {
		return $args->[0]->pprint();
	}	
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindOp.pl
## ------------------------------------------------------------

package FindOp;
@FindOp::ISA = qw(FindProc);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
    my $self = {'args' => [@_]};
    bless($self, $class);
    return $self;
}

sub clone {
	my $self = shift;
	my $clone = { 'args' => [@{$self->{'args'}}] };
	$clone->{'neg'} = $self->{'neg'} if ($self->{'neg'});
	bless($clone, ref($self));
	return $clone;
}


##
## Searching
##

sub negate {
	my $self = shift;
	my $clone = $self->clone();
	$clone->{'neg'} = $self->{'neg'} ? 0 : 1;
	return $clone;
}

sub setNegated {
	my $self = shift;
	$self->{'neg'} = 1;
	return $self;
}

sub dnf {
	my $self = shift;
	return FindOR->new(FindAND->new($self->clone())); 
}

sub find_init {
    my $self = shift;
    my $bindings = shift;
	my $args = $self->{'args'};

    # Find unbound variables
    my $bind = $self->{'bind'} = {};
	my @vars = grep {! defined($bindings->{$_})} keys(%{$self->unbound({})});
    map {$bind->{$_} = 0} @vars;

	# Set done flag to false
	$self->{'done'} = 0;
}

sub find_next {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = $self->{'bind'};
	my @vars = sort(keys(%$bind));

	# Return if constraint has terminated, or graph size is zero
	return undef if ($self->{'done'} || $#vars == -1);

	# Loop through all possible variable bindings
	my $result = {};
	while(1) {
	    #print "FO: " . join(" ", map {$_ . "=" . $bind->{$_}} keys(%$bind)) .  "\n";

		# Find first solution that does not precede current bindings
		my $bound = 0;
		while (! $bound) {
			# Find first legal binding that does not precede current
			# binding in the ordering
			for (my $v = $#vars; $v >= 0; --$v) {
				if ($bind->{$vars[$v]} >= $self->graphsize($graph, $bindings, $vars[$v])) {
					# Overflow in variable $v
					$bind->{$vars[$v]} = 0;

					# Carry overflow to next variable, or fail
					if ($v != 0) {
						# Increment variable $v-1
						$bind->{$vars[$v-1]} += 1;
					} else {
						# Overflow in last variable
						$self->{'done'} = 1;
						return undef;
					}
				} else {
					# No overflow
					last();
				}
			}

			# Let custom binder perform binding on last variable:
			# custom binder "next" returns "undef" if it doesn't know
			# a better binding than brute-force, 0 if it cannot find
			# other bindings of the current free variable, and 1 if it
			# found a possible candidate for binding.
			$bound = 1;
			my $next = $self->next($graph, $bindings, $bind, @vars);
			if (defined($next) && $next == 0) {
				# Custom binder exhausted all bindings of last variable
				$bind->{$vars[$#vars]} = $self->graphsize($graph, $bindings, $vars[$#vars]);
				$bound = 0;
			} 
		}

		# Return undef if we have exhausted all bindings
		if ($bind->{$vars[0]} >= $self->graphsize($graph, $bindings, $vars[0])) {
			$self->{'done'} = 1;
			return undef;
		}

		# Check whether the variable binding satisfies the constraint,
		# and exit if we have a match
		my $match = $self->match($graph, $bindings, $bind);	
		$match = $self->{'neg'} ? (! $match) : $match;
		if ($match) {
			# Copy local bindings, increment local bindings, and exit
			map {$result->{$_} = $bind->{$_}} keys(%$bind);
			$bind->{$vars[$#vars]} += 1;
			return $result;
		} else {
			# Increment local bindings, then continue searching
			$bind->{$vars[$#vars]} += 1;
		}
	}
}

##
## Dummy procedures: should be defined by subclasses
## 

sub solve {
	return [];
}

sub next {
	# Return undefined by default
	return undef;
}

sub match {
	# Return undefined by default
	return undef;
}

sub vars {
	# Return no variables by default
	return [];
}

sub unbound {
	# Return all unbound variables in simple constraint: this must be
	# overridden for complex constraints like FindAND, FindOR,
	# FindEXIST
	my $self = shift;
	my $unbound = shift;

	# Mark all unbound variables in hash $unbound
	map {$unbound->{$self->{'args'}[$_]} = 1} @{$self->vars()};

	# Return
	return $unbound;
}

sub graphsize {
	my ($self, $graph, $bindings, $var) = @_;
	my $key = $self->varkey($bindings, $var);
	my $keygraph = $graph->graph($key);
	if (! defined($keygraph)) {
		DTAG::Interpreter::warning("Could not find graph for key " . ($key || "undef") .  "\n");
		return 0;
	}
	return $keygraph->size();
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindPath.pl
## ------------------------------------------------------------

package FindPATH;
@FindPATH::ISA = qw(FindOp);

sub vars {
	return [0,2];
}

sub match {
}

sub path {
	my $self = shift;
	my $graph = shift;
	my $binding = shift;
	my $bind = shift;
}

sub pprint {
	my $self = shift;
	my $type = ref($self);
	my $neg = ($self->{'neg'}) ? "!" : "";

	my $path = DTAG::Interpreter::dumper($self->{'args'}[1]);
	$path =~ s/^\$VAR1 = (.*);$/$1/;

	return "$neg$type(" . $self->{'args'}[0]  . ",$path," 
		. $self->{'args'}[2] . ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindProc.pl
## ------------------------------------------------------------

package FindProc;

sub utf8print {
    return 1;
}

sub print {
    my $self = shift;
    my $neg = $self->{'neg'} ? (utf8print() ? "¬" : "!") : "";
    my $type = ref($self);
    return "$type(" . join(",",
        map {UNIVERSAL::isa($_, 'FindProc') ? $_->print() : "$_"}
            @{$self->{'args'}}) . ")";
}

sub pprint {
    my $self = shift;
    my $neg = $self->{'neg'} ? (utf8print() ? "¬" : "!") : "";
    # Print 
    return "$neg" . $self->_pprint();
}

sub _pprint {
    my $self = shift;
    my $type = ref($self);
    return "$type(" . join(",",
        map {UNIVERSAL::isa($_, 'FindProc') ? $_->pprint() : "$_"}
            @{$self->{'args'}}) . ")";
}


sub keygraph {
	my ($self, $graph, $bindings) = (shift, shift, shift);
	my @vars = @_;
	my $key = $self->varkey($bindings, @vars);
	my $var1 = shift(@vars);
	foreach my $var (@vars) {
		my $nkey = $self->varkey($bindings, $var);
		if ($key ne $nkey) {
			$self->error($graph, "Variables " . join(" ", $var1, @vars) 
				. " must have the same key, but didn't: "
				. $var1 . "@" . $key . ","
				. $var . "@" . $nkey);
		}
	}
	return $graph->graph($key);
}

sub varkey {
	my ($self, $bindings, $var) = @_;
	my $key = $bindings->{'vars'}{defined($var) ? $var : ""};
	return defined($key) ? $key : "";
}

sub error {
	my $self = shift;
	my $graph = shift;
	my $error = shift;
	$graph->interpreter()->abort(1);
	DTAG::Interpreter::error($error . " in " . $self);
}

sub varbind {
    my $self = shift;
    my $bindings = shift;
    my $bind = shift;
    my $var = shift;

    return (defined($bind) && exists $bind->{$var})
        ? $bind->{$var}
        : $bindings->{$var};
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindStringEQ.pl
## ------------------------------------------------------------

package FindStringEQ;
@FindStringEQ::ISA = qw(FindOp);

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$self->{'args'}[0]->unbound($unbound);
	$self->{'args'}[1]->unbound($unbound);
	return $unbound;
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift || {};

	my $val1 = $self->{'args'}[0]->svalue($graph, $bindings, $bind);
	my $val2 = $self->{'args'}[1]->svalue($graph, $bindings, $bind);
	return defined($val1) && defined($val2) && ($val1 eq $val2);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'}; return "(" 
		. $args->[0]->pprint() . ($self->{'neg'} ? " ne " : " eq ") 
		. $args->[1]->pprint() . ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindStringRegExp.pl
## ------------------------------------------------------------

package FindStringRegExp;
@FindStringRegExp::ISA = qw(FindOp);

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$self->{'args'}[1]->unbound($unbound);
	return $unbound;
}   
					    
sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Variables
	my $val = $self->{'args'}[1]->svalue($graph, $bindings, $bind);
	my $regexp = $self->{'args'}[0];

	# Check existence of node and return result
	return 0 if (! (defined($val)  && defined($regexp)));
	return eval("\$val =~ $regexp") ? 1 : 0;
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return $args->[1]->pprint() . " =~ " . $args->[0];
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindStringValue.pl
## ------------------------------------------------------------

package FindStringValue;
@FindStringValue::ISA = qw(FindValue);

use overload
    '""' => \& pprint;
	    
sub unbound {
	my $self = shift;
	my $unbound = shift;
	return $unbound;
}

sub svalue {
	my $self = shift;
	return $self->{'args'}[0];	
}

sub value {
    my ($self, $graph, $bindings, $bind) = @_;
	return $self->svalue($graph, $bindings, $bind);
}

sub pprint {
	my $self = shift;
	return '"' . $self->{'args'}[0] . '"';
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindStringValueEtype.pl
## ------------------------------------------------------------

package FindStringValueEtype;
@FindStringValueEtype::ISA = qw(FindStringValue);

use overload
    '""' => \& pprint;

sub pprint {
	my $self = shift;
	my ($in, $out, $relpattern) = @{$self->{'args'}};
	return "etypes(" . $in . (defined($relpattern) ? 
		" " . $relpattern->pprint() : ",")
		. " " . $out . ")";
}

sub svalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Variables
	my ($invar, $outvar, $relpattern) = @{$self->{'args'}};
	return undef if (! (defined($invar) && defined($outvar)));

	# Find key graph
	my $keygraph = $self->keygraph($graph, $bindings, $invar);
	return undef if (! defined($keygraph));

	# Find node id and node
	my $inid = $self->varbind($bindings, $bind, $invar);
    my $outid = $self->varbind($bindings, $bind, $outvar);
	return undef if (! (defined($inid) && defined($outid)));

	# Find node
	my $innode = $keygraph->node($inid);
	return undef if (! defined($innode));
	
	# Find edge types for all matching edges
	my @etypes = ();
	foreach my $e (@{$innode->in()}) {
		my $etype = $e->type();
		push @etypes, DTAG::Interpreter::strip_relation($etype)
			if ($e->out() == $outid 
				&& ((! defined($relpattern)) 
					|| $relpattern->match($keygraph, $etype)));
	}

	# Find value
	return join(" ", sort(@etypes));
}


sub ask { 
	return 0; 
} 


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindStringValueNodeFeature.pl
## ------------------------------------------------------------

package FindStringValueNodeFeature;
@FindStringValueNodeFeature::ISA = qw(FindStringValue);

use overload
    '""' => \& pprint;

sub vars {
	return [1];
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my $node = $args->[0];
	my $feat = $args->[1];
	return $self->{'args'}[0]->pprint() . (defined($feat) ? "[" . $feat . "]" : "");
}

sub svalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Variables
	my $nodevar = $self->{'args'}[0];
	my $featvar = $self->{'args'}[1];
	#print "nodevar=$nodevar featvar=" . ($featvar || "") . "\n";
	return undef if (! defined($nodevar));

	# Find key graph
	my $keygraph = $self->keygraph($graph, $bindings, $nodevar);
	#print "keygraph=" . ($keygraph || "undef") . "\n";
	return undef if (! defined($keygraph));

	# Find node id and node
	my $nodeid = $nodevar->nvalue($graph, $bindings, $bind);
	return undef if (! defined($nodeid));

	# Find node
	my $node = $keygraph->node($nodeid);
	return undef if (! defined($node));

	# Find value
	my $val = defined($featvar)
		? $node->var($featvar)
		: $node->input();
	#print "$nodevar" . (defined($featvar) ? "[$featvar]" : "") 
	#	. " ($nodeid) = " . (defined($val) ? $val : "_undef") . "\n";
	return defined($val) ? "" . $val : undef;
}

sub unbound {
	my $self = shift;
	my $unbound = shift;
	return $self->{'args'}[0]->unbound($unbound);
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindType.pl
## ------------------------------------------------------------

package FindType;
@FindType::ISA = qw(FindProc);

use overload
    '""' => \& print;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
    my $self = {'args' => [@_]};
    bless($self, $class);
    return $self;
}

sub print {
	my $self = shift;
	return $self->pprint();
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindTypeAtomic.pl
## ------------------------------------------------------------

package FindTypeAtomic;
@FindTypeAtomic::ISA = qw(FindType);

sub shortname {
	my $relset = shift;
	my $rel = shift;
	return exists $relset->{$rel} 
		? $relset->{$rel}[0] : undef;
}

sub match {
    my $self = shift;
    my $graph = shift;
    my $string = shift;
	my $relset = shift;
    my $tparent = $self->{'args'}[0];
	
    # Check for equality
	my $subtypes_only = $self->{'args'}[1];
    return 1 if ($tparent eq $string && ! $subtypes_only);

	# Retrieve canonical names and check for existence and equality
	$string = shortname($relset, $string);
	$tparent = shortname($relset, $tparent);
	return 0 if (! (defined($string) && defined($tparent)));
	return 1 if ($string eq $tparent && ! $subtypes_only);

    # Check relation set   
    return $relset->{$string}[$REL_TPARENTS]->{$tparent};
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return '"' . $args->[0] . '"';
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindTypeMinus.pl
## ------------------------------------------------------------

package FindTypeMinus;
@FindTypeMinus::ISA = qw(FindType);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $relset = shift;
	my $args = $self->{'args'};

	# Return 1 if any arg matches, otherwise 0
	return 0 if (! $args->[0]->match($graph, $string, $relset));
	for (my $i = 1; $i <= $#$args; ++$i) {
		return 0 if ($args->[$i]->match($graph, $string, $relset));
	}
	return 1;
}

sub pprint {
    my $self = shift;
    my $args = $self->{'args'};
    return "(" . join("-", map {$_->pprint()} @$args) . ")";
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindTypeNot.pl
## ------------------------------------------------------------

package FindTypeNot;
@FindTypeNot::ISA = qw(FindType);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $relset = shift;
	my $args = $self->{'args'};

	# Return the negation of $arg match
	return ! $args->[0]->match($graph, $string, $relset);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return '(-' . $args->[0]->pprint() . ')';
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindTypeOr.pl
## ------------------------------------------------------------

package FindTypeOr;
@FindTypeOr::ISA = qw(FindType);

use overload
    '""' => \& print;

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $relset = shift;
	my $args = $self->{'args'};

	# Return 1 if any arg matches, otherwise 0
	foreach my $arg (@$args) {
		return 1
			if ($arg->match($graph, $string, $relset));
	}
	return 0;
}

sub pprint {
    my $self = shift;
    my $args = $self->{'args'};
    return "(" . join("|", map {$_->pprint()} @$args) . ")";
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindTypePlus.pl
## ------------------------------------------------------------

package FindTypePlus;
@FindTypePlus::ISA = qw(FindType);

use overload
    '""' => \& print;

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $relset = shift;
	my $args = $self->{'args'};

	# Return 0 if any arg fails to match, otherwise 1
	foreach my $arg (@$args) {
		return 0
			if (! $arg->match($graph, $string, $relset));
	}
	return 1;
}

sub pprint {
    my $self = shift;
    my $args = $self->{'args'};
    return "(" . join("+", map {$_->pprint()} @$args) . ")";
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindValue.pl
## ------------------------------------------------------------

package FindValue;
@FindValue::ISA = qw(FindProc);

use overload
    '""' => \& pprint;

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
    my $self = {'args' => [@_]};
    bless($self, $class);
    return $self;
}

sub pprint {
	return "FindValue";
}

sub clone {
	my $self = shift;
	my $clone = { 'args' => [@{$self->{'args'}}] };
	bless($clone, ref($self));
	return $clone;
}

sub value {
	return undef;
}

## ------------------------------------------------------------
##  start auto-insert from directory: .svn
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: tmp
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  start auto-insert from directory: prop-base
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: prop-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: props
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: props
## ------------------------------------------------------------
## ------------------------------------------------------------
##  start auto-insert from directory: text-base
## ------------------------------------------------------------
# 
# LICENSE
# Copyright (c) 2002-2009 Matthias Buch-Kromann <mbk.isv@cbs.dk>
# 
# The code in this package is free software: You can redistribute it
# and/or modify it under the terms of the GNU General Public License 
# published by the Free Software Foundation. This package is
# distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY or any implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more
# details. 
# 
# The GNU General Public License is contained in the file LICENSE-GPL.
# Please consult the DTAG homepages for more information about DTAG:
#
#	http://code.google.com/p/copenhagen-dependency-treebank/wiki/DTAG
# 
# Matthias Buch-Kromann <mbk.isv@cbs.dk>
#

## ------------------------------------------------------------
##  stop auto-insert from directory: text-base
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: tmp
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: .svn
## ------------------------------------------------------------
## ------------------------------------------------------------
##  stop auto-insert from directory: FindOps
## ------------------------------------------------------------

1;
