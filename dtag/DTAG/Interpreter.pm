# 
# LICENSE
# Copyright (c) 2002-2003 Matthias Trautner Kromann <mtk@id.cbs.dk>
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
#     http://sf.net/projects/disgram/
#     http://www.id.cbs.dk/~mtk/dtag
# 
# Matthias Trautner Kromann
# mtk@id.cbs.dk
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
use XML::Writer;
#use XML::Parser;
use PerlIO;
use IO qw(File);
use File::Basename;
use Encode;

# Required DTAG modules 
require DTAG::Lexicon;
require DTAG::LexInput;
require DTAG::Learner;

# Interpreted Perl: arg-list
my @perl_args = ();

# Variables
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
##  auto-inserted from: Interpreter/LANGUAGE.pl
## ------------------------------------------------------------

# Query language grammar
my $probmodel_grammar = q{
	distribution 
		: 'distribution(' blanks '"' name '"' blanks ')'
			{Distribution->new($item[4]) }
		| 'explanatory' distribution_head
			{ $item[2]->option('explanatory', 1) }
	
	


	blank	: /\s+/						{ $item[1] }

	blanks	: /\s*/						{ $item[1] }

	name	: /[a-zA-Z0-9_]+/			{ $item[1] }

	number	: /[0-9]+/					{ $item[1] }
		
	range 	: number '-' number			{ [$item[1], $item[3]] }
			| number					{ [$item[1], $item[1]] }

	regexp  : /\/[^\/\s]+\// 			{ $item[1] }

	node 	: /\$/ name 				{ $item[1] . $item[2] }

	edge 	: name 						{ $item[1] }
			| "'" /[^\s']+/ "'" 		{ $item[2] }
			| regexp 					{ $item[1] }

	typename: name						{ $item[1] }

	var 	: name 						{ $item[1] }

	stype 	: '(' blanks type blanks ')'{ $item[3] }
			| typename					{ $item[1] }

	type 	: '-' blanks type			{ [ '-', $item[3]] }
			| stype blanks '+' blanks type
										{ [ '+', $item[1], $item[5]] }
			| stype blanks '-' blanks type
										{ [ '-', $item[1], $item[5]] }
			| stype blanks '|' blanks type		
										{ [ '|', $item[1], $item[5]] }
			| stype						{ $item[1] }

	spath	: '>' edge					{ ['>', $item[2]] }
			| '<' edge					{ ['<', $item[2]] }
			| '{' spath '}+' 			{ ['+', $item[2]] }

	path	: spath path				{ [@{$item[1]}, @{$item[2]}] }
			| spath						{ $item[1] }

	sexpr   : '(' blanks expr blanks ')'		{ $item[3] }
			| node blanks '>>' blanks node 
								{	FindADJ->new($item[1],
										$item[5], [1,1], -1); }
			| node blanks '<<' blanks node 
								{	FindADJ->new($item[1],
										$item[5], [1,1], 1); }
			| node blanks '>' range '>' blanks node 
								{	FindADJ->new($item[1],
										$item[7], $item[4], -1); }
			| node blanks '<' range '<' blanks node
								{	FindADJ->new($item[1],
										$item[7], $item[4], 1); }
			| node blanks '<' blanks node
								{ FindLT->new($item[1], $item[5]) }
			| node blanks '>' blanks node
								{ FindGT->new($item[1], $item[5]) }
			| node blanks '<=' blanks node
								{ my $obj = FindGT->new($item[1], $item[5]); 
									$obj->{'neg'} = 1; $obj }
			| node blanks '>=' blanks node
								{ my $obj = FindLT->new($item[1], $item[5]);
									$obj->{'neg'} = 1; $obj }
			| node blanks '!=' blanks node
								{ my $obj = FindEQ->new($item[1], $item[5]); 
									$obj->{'neg'} = 1; $obj }
			| node blanks '==' blanks node 	
								{ FindEQ->new($item[1], $item[5]) }
			| node ':' type
								{ FindINH->new($item[1], $item[3]) }
			| node blank 'isa' blank type
								{ FindINH->new($item[1], $item[5]) }
			| node blanks '=~' blanks regexp
								{ FindRE->new($item[1], '_input', $item[5]) }
			| node '[' var ']' blanks '=~' blanks regexp
								{ FindRE->new($item[1], $item[3], $item[8]) }
			| node blank 'path(' path ')' blank node
								{ FindPATH->new($item[1], $item[4], $item[7]) }
			| node blank edge blank node 	
								{ FindEDGE->new($item[1], $item[3], $item[5]) }

	expr	: 'exist(' blanks node blanks ',' blanks expr blanks ')'
								{ FindEXIST->new($item[3], $item[7]) }
			| 'exists(' blanks node blanks ',' blanks expr blanks ')'
								{ FindEXIST->new($item[3], $item[7]) }
			| 'all(' blanks node blanks ',' blanks expr blanks ')'
								{ my $obj = FindEXIST->new($item[3], 
									FindNOT->new($item[7])); $obj->{'neg'} = 1;
									$obj }
			| '!' blanks expr	{ FindNOT->new($item[3]) }
			| sexpr blanks ',' blanks expr
								{ FindAND->new($item[1], $item[5]) }
			| sexpr blanks '&' blanks expr	
								{ FindAND->new($item[1], $item[5]) }
			| sexpr blanks '|' blanks expr
								{ FindOR->new($item[1], $item[5]) }
			| sexpr blanks '=>' blanks expr	
								{ FindOR->new(FindNOT->new($item[1]), 
									$item[5])}
			| sexpr				{ $item[1] }

    findkey_expr : '"' /[^"]+/ '"'  
					{ 'sub { return find_key(shift, shift, shift, '
									. "'$item[2]')};" }

	find_expr : '-debug' blank find_expr 
			{$item[3]->{'debug'} = 1; $item[3]}
		| '-parse' blank find_expr 
			{$item[3]->{'debug_parse'} = 1; $item[3]}
		| '-dnf' blank find_expr 
			{$item[3]->{'debug_dnf'} = 1; $item[3]}
		| '-safe' blank find_expr
			{$item[3]->{'safe'} = 1; $item[3]}
		| '-corpus' blank find_expr 
			{$item[3]->{'corpus'} = 1; $item[3]}
		| '-secure' blank find_expr 
			{$item[3]->{'secure'} = 1; $item[3]}
		| '-timeout=' /[0-9]+/ blank find_expr 
			{$item[4]->{'timeout'} = $item[2]; $item[4] }
		| '-matchout=' /[0-9]+/ blank find_expr 
			{$item[4]->{'matchout'} = $item[2]; $item[4] }
		| '-key(' findkey_expr /\)/ blank find_expr
			{ $item[5]->{'key'} = $item[2]; $item[5] }
		| '-text(' findkey_expr /\)/ blank find_expr
			{ $item[5]->{'text'} = $item[2]; $item[5] }
		| '-do(' /[^)]+/ /\)/ blank find_expr
			{ $item[5]->{'replace'} = [] if (! $item[5]->{'replace'}); 
				push @{$item[5]->{'replace'}}, $item[2]; $item[5] }
		| '-replace(' /[^)]+/ /\)\s*/ blank find_expr
			{ $item[5]->{'replace'} = [] if (! $item[5]->{'replace'}); 
				push @{$item[5]->{'replace'}}, $item[2]; $item[5] }
		| expr	
			{ {'query' => $item[1]} }

};

# Parser object
#my $query_parser = undef;
#$Parse::RecDescent::skip = '';



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/PARSER.pl
## ------------------------------------------------------------

# Query language grammar
my $query_grammar = q{
	blank	: /\s+/						{ $item[1] }

	blanks	: /\s*/						{ $item[1] }

	name	: /[a-zA-Z0-9_]+/			{ $item[1] }

	number	: /[0-9]+/					{ $item[1] }
		
	range 	: number '-' number			{ [$item[1], $item[3]] }
			| number					{ [$item[1], $item[1]] }

	regexp  : /\/[^\/\s]+\// 			{ $item[1] }

	node 	: /\$/ name 				{ $item[1] . $item[2] }

	edge 	: name 						{ $item[1] }
			| "'" /[^\s']+/ "'" 		{ $item[2] }
			| regexp 					{ $item[1] }

	typename: name						{ $item[1] }

	var 	: name 						{ $item[1] }

	stype 	: '(' blanks type blanks ')'{ $item[3] }
			| typename					{ $item[1] }

	type 	: '-' blanks type			{ [ '-', $item[3]] }
			| stype blanks '+' blanks type
										{ [ '+', $item[1], $item[5]] }
			| stype blanks '-' blanks type
										{ [ '-', $item[1], $item[5]] }
			| stype blanks '|' blanks type		
										{ [ '|', $item[1], $item[5]] }
			| stype						{ $item[1] }

	spath	: '>' edge					{ ['>', $item[2]] }
			| '<' edge					{ ['<', $item[2]] }
			| '{' spath '}+' 			{ ['+', $item[2]] }

	path	: spath path				{ [@{$item[1]}, @{$item[2]}] }
			| spath						{ $item[1] }

	sexpr   : '(' blanks expr blanks ')'		{ $item[3] }
			| node blanks '>>' blanks node 
								{	FindADJ->new($item[1],
										$item[5], [1,1], -1); }
			| node blanks '<<' blanks node 
								{	FindADJ->new($item[1],
										$item[5], [1,1], 1); }
			| node blanks '>' range '>' blanks node 
								{	FindADJ->new($item[1],
										$item[7], $item[4], -1); }
			| node blanks '<' range '<' blanks node
								{	FindADJ->new($item[1],
										$item[7], $item[4], 1); }
			| node blanks '<' blanks node
								{ FindLT->new($item[1], $item[5]) }
			| node blanks '>' blanks node
								{ FindGT->new($item[1], $item[5]) }
			| node blanks '<=' blanks node
								{ my $obj = FindGT->new($item[1], $item[5]); 
									$obj->{'neg'} = 1; $obj }
			| node blanks '>=' blanks node
								{ my $obj = FindLT->new($item[1], $item[5]);
									$obj->{'neg'} = 1; $obj }
			| node blanks '!=' blanks node
								{ my $obj = FindEQ->new($item[1], $item[5]); 
									$obj->{'neg'} = 1; $obj }
			| node blanks '==' blanks node 	
								{ FindEQ->new($item[1], $item[5]) }
			| node ':' type
								{ FindINH->new($item[1], $item[3]) }
			| node blank 'isa' blank type
								{ FindINH->new($item[1], $item[5]) }
			| node blanks '=~' blanks regexp
								{ FindRE->new($item[1], '_input', $item[5]) }
			| node '[' var ']' blanks '=~' blanks regexp
								{ FindRE->new($item[1], $item[3], $item[8]) }
			| node blank 'path(' path ')' blank node
								{ FindPATH->new($item[1], $item[4], $item[7]) }
			| node blank edge blank node 	
								{ FindEDGE->new($item[1], $item[3], $item[5]) }

	expr	: 'exist(' blanks node blanks ',' blanks expr blanks ')'
								{ FindEXIST->new($item[3], $item[7]) }
			| 'exists(' blanks node blanks ',' blanks expr blanks ')'
								{ FindEXIST->new($item[3], $item[7]) }
			| 'all(' blanks node blanks ',' blanks expr blanks ')'
								{ my $obj = FindEXIST->new($item[3], 
									FindNOT->new($item[7])); $obj->{'neg'} = 1;
									$obj }
			| '!' blanks expr	{ FindNOT->new($item[3]) }
			| sexpr blanks ',' blanks expr
								{ FindAND->new($item[1], $item[5]) }
			| sexpr blanks '&' blanks expr	
								{ FindAND->new($item[1], $item[5]) }
			| sexpr blanks '|' blanks expr
								{ FindOR->new($item[1], $item[5]) }
			| sexpr blanks '=>' blanks expr	
								{ FindOR->new(FindNOT->new($item[1]), 
									$item[5])}
			| sexpr				{ $item[1] }

    findkey_expr : '"' /[^"]+/ '"'  
					{ 'sub { return find_key(shift, shift, shift, '
									. "'$item[2]')};" }

	find_expr : '-debug' blank find_expr 
			{$item[3]->{'debug'} = 1; $item[3]}
		| '-parse' blank find_expr 
			{$item[3]->{'debug_parse'} = 1; $item[3]}
		| '-dnf' blank find_expr 
			{$item[3]->{'debug_dnf'} = 1; $item[3]}
		| '-safe' blank find_expr
			{$item[3]->{'safe'} = 1; $item[3]}
		| '-corpus' blank find_expr 
			{$item[3]->{'corpus'} = 1; $item[3]}
		| '-secure' blank find_expr 
			{$item[3]->{'secure'} = 1; $item[3]}
		| '-timeout=' /[0-9]+/ blank find_expr 
			{$item[4]->{'timeout'} = $item[2]; $item[4] }
		| '-matchout=' /[0-9]+/ blank find_expr 
			{$item[4]->{'matchout'} = $item[2]; $item[4] }
		| '-key(' findkey_expr /\)/ blank find_expr
			{ $item[5]->{'key'} = $item[2]; $item[5] }
		| '-text(' findkey_expr /\)/ blank find_expr
			{ $item[5]->{'text'} = $item[2]; $item[5] }
		| '-do(' /[^)]+/ /\)/ blank find_expr
			{ $item[5]->{'replace'} = [] if (! $item[5]->{'replace'}); 
				push @{$item[5]->{'replace'}}, $item[2]; $item[5] }
		| '-replace(' /[^)]+/ /\)\s*/ blank find_expr
			{ $item[5]->{'replace'} = [] if (! $item[5]->{'replace'}); 
				push @{$item[5]->{'replace'}}, $item[2]; $item[5] }
		| expr	
			{ {'query' => $item[1]} }

};

# Parser object
my $query_parser = undef;
$Parse::RecDescent::skip = '';



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
    my $align = DTAG::Alignment->new();
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
##  auto-inserted from: Interpreter/cmd_adjuncts.pl
## ------------------------------------------------------------

sub cmd_adjuncts {
	my $self = shift;
	my $graph = shift;
	my $adjuncts = shift || "";

	# Copy default etypes to graph etypes, if no etypes for graph
	my $etypes = {
		'adj' => [grep {$_} split(/\s+/, $adjuncts)]
	};
	$graph->etypes($etypes);

	# Return
	return 1;
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
	my $align = DTAG::Alignment->new();

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
				my $sublexicon = $alexicon->new_sublexicon();
				$sublexicon->train($alignment);
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
	my $agraph = DTAG::Alignment->new();
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
##  auto-inserted from: Interpreter/cmd_cd.pl
## ------------------------------------------------------------

sub cmd_cd {
	my $self = shift;
	my $dir = (shift) || "";

	# Change to new directory
	chdir($dir);

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
			my $new = DTAG::Graph->new();
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
##  auto-inserted from: Interpreter/cmd_complements.pl
## ------------------------------------------------------------

sub cmd_complements {
	my $self = shift;
	my $graph = shift;
	my $complements = shift || "";

	# Copy default etypes to graph etypes, if no etypes for graph
	my $etypes1 = {
		'comp' => [grep {$_} split(/\s+/, $complements)]
	};
	$graph->etypes($etypes1);

	# Return
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_compound.pl
## ------------------------------------------------------------

sub cmd_compound {
	my $self = shift;
	my $graph = shift;
	my $noder = shift;
	my $arg = shift;
	$arg =~ s/^\s+(\S)/$1/g;

	# Apply offset
	my $node = defined($noder) ? $noder + $graph->offset() : undef;

	# Find node 
	my $N = $graph->node($node);
	if ($arg) {
		$N->var('compound', $arg);
	}
	
	# Errors: non-existent node, or comment node
	return error("Non-existent node: $noder") if (! $N);
	return error("Node $noder is a comment node.") if ($N->comment());


	# Mark graph as modified and add existing compound
	my $compound = $N->var('compound') || $N->input();
	if ((! $arg) && $compound) {
		$self->nextcmd("compound $noder $compound");
	} 
	$graph->mtime(1);

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
##  auto-inserted from: Interpreter/cmd_del.pl
## ------------------------------------------------------------

sub cmd_del {
	my $self = shift;
	my $graph = shift;
	my $nodeinr = shift;
	my $etype = shift;
	my $nodeoutr = shift;

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
	if ($graph->{'block_nodedel'}) {
		print "WARNING: Node deletion turned off: only incoming edges deleted\n";
		print "Please use \"edel <node>\" when deleting in-edges\n";
		print "Node deletion can be turned on/off with \"del -on\" / \"del -off\"\n";
		$self->cmd_edel($graph, $nodeinr);
	} elsif (! defined($etype)) {
		# Delete node
		splice(@{$graph->nodes()}, $nodein, 1);

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
	$self->cmd_load(DTAG::Graph->new(), undef, $file);
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
		foreach my $label ((sort {($stats->{$b}[0] + $stats->{$b}[1]) 
				<=> ($stats->{$a}[0] + $stats->{$a}[1])
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
				($stats->{$label}[0], $stats->{$label}[1],
				$stats->{$label}[2], $stats->{$label}[3]);

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
		}

		# Print unlabelled total scores
		my ($total, $proposed, $correct, $correct_unlbl) = 
			($stats->{'TOTAL'}[0], $stats->{'TOTAL'}[1],
			$stats->{'TOTAL'}[2], $stats->{'TOTAL'}[3]);
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
			($stats->{'TOTAL1'}[0], $stats->{'TOTAL1'}[1],
			$stats->{'TOTAL1'}[2], $stats->{'TOTAL1'}[3]);
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
		print "\n\nRelative annotation time for automatic relative to manual annotation\n    = (GOLD-CORRECT)/GOLD + 2*(PROPOSED-CORRECT)/GOLD = "
			. sprintf("%.1f%%\n", 100 * (
				($total - $correct) / $total 
					+ 2 * ($proposed - $correct) / $total));
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

	# Add edge and mark graph as modified
	$graph->edge_add(Edge->new($nodein, $nodeout, $etype));

	# Update graph as modified
	$graph->mtime(1);
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
##  auto-inserted from: Interpreter/cmd_exit.pl
## ------------------------------------------------------------

sub cmd_exit {
	my $self = shift;
	my $graph = shift;

	# Save file if modified
	if ($graph && $graph->mtime()) {
	}

	# Only exit from the outer loop
	if ($self->{'loop_count'} > 1) {
		return 1;
	};

	# Close lexicon
	my $lex = $self->lexicon();
	$lex->close() if ($lex);

	# Close viewers
	local $SIG{INT} = 'IGNORE';
	kill('INT', -$$);

	# Delete follow files
	unlink($graph->fpsfile()) if ($graph && $graph->fpsfile());
	unlink($self->fpsfile()) if ($self && $self->fpsfile());

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
	my $parse = $self->query_parser()->find_expr(\$cmd2);
	my $query = $parse->{'query'};
	my $replace = $parse->{'replace'} || [];
	my $key = $parse->{'key'};
	my $text = $parse->{'text'};
	my $timeout = $parse->{'timeout'} || "0";
	my $matchout = $parse->{'matchout'} || "0";
	my $debug = $parse->{'debug'};
	my $debug_parse = $parse->{'debug_parse'};
	my $debug_dnf = $parse->{'debug_dnf'};
	my $corpus = $parse->{'corpus'};
	my $safe = $parse->{'safe'};
	if ($cmd2) {
		# String was not parsed completely
		error("Illegal search query: error in \"$cmd2\"");
		return 1;
	}

	# Print debugging output of parse
	if ($debug_parse || $debug_dnf || $debug) {
		$self->print("find", "result", 
			"input=$cmd\n"
			. ("query=" 
				. ((ref($query) && UNIVERSAL::can($query, "print")) 
					? $query->print() : dumper($query)) . "\n")
			. ((ref($query) && UNIVERSAL::isa($query, 'HASH'))
				? "vars=" . join(" ", sort(keys(%{$query->unbound({})})))
					. "\n" 
				: "")
			. (@$replace ? "replace=" . join(" | ", @$replace) . "\n" : "")
			. ($key ? "key=$key\n" : "")
			. ($text ? "text=$text\n" : "")
			. (defined($timeout) ? "timeout=$timeout\n" : "")
			. (defined($matchout) ? "matchout=$matchout\n" : ""));
		return 1 if ($debug_parse);
	}

	# Compile key and text subroutines
	my $keysub = $key ? eval($key) : sub { undef };
	my $textsub = $text ? eval($text) : sub { undef };
	my ($keystr, $textstr);

	# Reduce query string to disjunctive normal form
	my $dnf = ref($query) ? $query->dnf() : undef;
	if ($debug_dnf || $debug) {
		$self->print("find", "result", 
			"dnf=" . (ref($dnf) ? $dnf->print() : dumper($dnf)) . "\n");
		return 1 if ($debug_dnf);
	}

	# Reset found matches and disable follow
	my $matches = $self->{'matches'} = {};
	my $maxsols = 1000;				# Maximal number of full solutions
	my $oldfpsfile = $self->{'fpsfile'};
	$self->{'fpsfile'} = undef;

	# Solve DNF-query for all files in corpus
	my $iostatus = $|; $| = 1; my $c = 0;
	my $progress = "";
	my $findfiles = $corpus ? $self->{'corpus'} : [$self->graph()->graph_id()];
	my $count = 0;
	my $display = 1;
	my $ask = $self->interactive();
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
				my $percent = int(100 * $c / (1 + $#{@$findfiles}));
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
				$and->solve($graph, $maxsols, {});
			if (@$solutions) {
				$matches->{$f} = [] if (! $matches->{$f});

				# Process solutions
				foreach my $s (@$solutions) {
					$keystr = &$keysub($self, $graph, $s);
					$s->{'key'} = $keystr if ($keystr);
					$textstr = &$textsub($self, $graph, $s);
					$s->{'text'} = $textstr if ($textstr);
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
		if (@$replace && ! $safe) {
			my $choice = "N";
			foreach my $binding (@{$matches->{$f}}) {
				# Select replace operation
				$choice = "Y";
				if ($ask) {
					# Update graph
					++$match;
					$self->{'fpsfile'} = $oldfpsfile;
					$self->cmd_goto("M$match");
					$self->{'fpsfile'} = undef;

					# Print replace operations
					print "Replace operations for ",
						$self->print_match($match, $f, $binding), "\n",
						"    [Y]es [N]o [A]ll [Q]uit [E]dit [D]isplay\n";
					my $i = 0;
					if (scalar(@$replace) > 1) {
						foreach my $cmd (@$replace) {
							print "    [", substr($key_names, $i++, 1), 
								"]: $cmd\n";
						}
					}

					# Read choice
					my $choices = "YNAQE0" 
						. substr($key_names, 0, scalar(@$replace));
					$choice = " ";
					#ReadMode('cbreak') if (! $broken_ReadKey); 
					while (ReadKey(-1)) { };		# ignore any input
					while ($choices !~ /$choice/) {
						$choice = ($broken_ReadKey ? getc() : ReadKey(-1)) 
							|| "_";
						print "[$choice]";
						sleep(1);

						# Change display
						$display = $display ^ 2 
							if ($choice eq "D");
					}
					#ReadMode('normal') if (! $broken_ReadKey); 
				}

				# Process choice: AYN0
				if ($choice eq "N" || $choice eq "0") { next() };
				if ($choice eq "Q") { last() };
				if ($choice eq "Y") { $choice = "1" };
				if ($choice eq "A") { $ask = 0; $choice = "1" };

				# Manual edit or automatic replacement
				if ($choice eq "E") {
					# Manual edit
					$self->{'fpsfile'} = $oldfpsfile;
					$self->loop();
					$self->{'fpsfile'} = undef;
					next();
				} else {
					# Automatic replacement
					my $id = index($key_names, $choice);
					my $op = $replace->[$id];

					# Replace variables with bindings
					foreach my $var (keys(%$binding)) {
						my $val = $binding->{$var};
						$var = '\\' . $var;
						$op =~ s/$var/$val/g;
					}
					print "    Operation: $op\n" if ($ask);

					# Execute replace commands
					foreach my $c (split(";", $op)) {
						$self->do($c);
					}
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

    # Print search statistics
	$time += time();
	print "$count matches found in " . seconds2hhmmss($time) 
		. " for query \"$cmd\".\n" if (! $self->quiet());

	# Restore old fpsfile
	$self->{'fpsfile'} = $oldfpsfile;

	# Show first match
	$self->cmd_goto('M1') if ($count);

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
##  auto-inserted from: Interpreter/cmd_goto.pl
## ------------------------------------------------------------

sub cmd_goto {
	my $self = shift;
	my $cmd = shift || 0;
	my $mod = shift;

	if ($cmd =~ s/^-context\s+([0-9]+)\s*//) {
		# Set goto context size
		$self->var('goto_context', $1 || 0);
	} elsif ($cmd =~ /^\s*[GA]([0-9]+)\s*$/) {
		# Goto graph specified by graph id
		$self->goto_graph($1 - 1);
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
	my $from = shift;
	my $to = shift;

	# Store alignment edge in graph (in toggle fashion, so it is
	# deleted if it already exists)
	if (exists $graph->{'inalign'}{"$from $to"}) {
		delete $graph->{'inalign'}{"$from $to"};
	} else {
		$graph->{'inalign'}{"$from $to"} = 1;
	}

	# Return
	return 1;
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
			= eval("sub {my \$v = \"\" . shift(); \$v =~ $2; \$v}");
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

	# Process options: permitted options {multi=0/1 (create new graph,
	# add to current graph)}
	my $multi = 0;
	$multi = 1 if ($optionstr =~ /-multi/);

    # Open internal graph if $file is an internal graph reference
    if ($fname =~ /^\[[GA]([0-9]+)\]$/) {
        my @graphs = @{$self->{'graphs'}};
        for (my $g = 0; $g < scalar(@graphs); ++$g) {
            if ($graphs[$g]->graph_id() eq $fname) {
                $self->{'graph'} = $g;
                $self->cmd_return($graphs[$g]);
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
		$ftype = '-lex' if ($fname =~ /\.lex$/);
		$ftype = '-match' if ($fname =~ /\.match$/);
		$ftype = '-tiger' if ($fname =~ /\.xml$/);
		$ftype = '-malt' if ($fname =~ /\.malt$/);
		$ftype = '-conll' if ($fname =~ /\.conll$/);
	}

	# Load file
	$self->cmd_load_tag($graph, $fname, $multi) if ($ftype eq '-tag');
	$self->cmd_load_atag($graph, $fname) if ($ftype eq '-atag');
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
	my $viewer = $self->{'viewer'};
	$self->cmd_load_closegraph($graph) if ($graph);

	# Create new graph 
	my $alignment = DTAG::Alignment->new();
	$alignment->file($file);
	my $lastgraph = $graph;

	# Read ATAG file line by line
	open("ATAG", "< $file") 
		|| return error("cannot open atag-file for reading: $file");
	$self->{'viewer'} = 0;
    while (my $line = <ATAG>) {
        chomp($line);

		# Process file
		if ($line =~ 
				/^<alignFile key="([a-z])" href="([^"]*)" sign="([^"]*)"\/>$/) {
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
		} elsif ( $line =~
				/^<align out="([^"]+)" type="([^"]*)" in="([^"]+)" creator="(-[0-9]+)".*\/>$/ 
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
			$self->cmd_align($alignment, $out, $type, $in, $creator, 0);
		} elsif ($line =~ /<\/?DTAGalign>/) {
			# Do nothing
		} else {
			print "ignored: $line\n" if (! $self->quiet());
		}
	}

	# Close ATAG file
	close("ATAG");

	# Push alignment on top of graph stack
	$self->{'viewer'} = $viewer;
	push @{$self->{'graphs'}}, $alignment;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	$self->cmd_return($self->graph());
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
	$graph = DTAG::Graph->new();
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
	$graph = DTAG::Graph->new();
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
		$graph = DTAG::Graph->new();
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
						my $etype = $2;
						my $edge;

						# Create edge
						if ($var eq "in") {
							$edge = Edge->new($pos, $1+$pos, $2);
						} elsif ($var eq "out") {
							$edge = Edge->new($1+$pos, $pos, $2);
						}
						
						# Create edge if possible
						if ($pos2 <= $pos) {
							$graph->edge_add($edge);
						} else {
							push @edges, $edge;
						}
					}
				} else {
					# Ordinary variable
					$varnames->{$var} = 1;
					$n->var($var, $vars->{$var});
				}
			}
		} elsif ($line =~ /^\s*<!--\s*<inalign>([\d+]+)\s+([\d+]+)<\/inalign>\s*-->\s*$/) {
			# XML comment representing inalign edge
			$self->cmd_inalign($graph, $1, $2);
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
	$graph = DTAG::Graph->new();
	$graph->file($file);
	push @{$self->{'graphs'}}, $graph;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# Inform user about action
	print "Importing data from TIGER XML file $file\n" 
		if (!  $self->quiet());

	# Head edge
	my $HEADEDGE = "--";

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
		error("Usage: maptags [-mapfile $mapfile] $invar $outvar\n");
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
	push @{$self->{'graphs'}}, DTAG::Graph->new();

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
##  auto-inserted from: Interpreter/cmd_offset.pl
## ------------------------------------------------------------

sub cmd_offset {
	my $self = shift;
	my $graph = shift;
	my $sign = shift || "+";
	my $number = shift || "0";

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

	if (defined($value)) {
		# Set option (if value given)
		$self->{'options'}{$option} = $value;
	} else {
		# Print option
		print "option $option=", ($self->{'options'}{$option} || 'undef'), "\n";
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
		: [$self->graph()->graph_id()];
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
		my $pcmd = '$L = pop(@perl_args); $G = pop(@perl_args); '
				. '$I = pop(@perl_args); ' . $cmd;

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
		#open(PSFILE, ">:encoding(iso-8859-1)", $file . "~") 
		#open(PSFILE, ">:utf8", $tmpfile) 
		open(PSFILE, ">", $tmpfile) 
			|| return error("cannot open file $file for printing!");
		print PSFILE $ps;
		close(PSFILE);
		my $iconv = $self->{'options'}{'iconv'} || 'cat';
		my $cmd = $iconv . " $tmpfile > $file";
		system($cmd);
		system("rm $tmpfile");
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
##  auto-inserted from: Interpreter/cmd_resume.pl
## ------------------------------------------------------------

sub cmd_resume {
	my $self = shift;
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
		print "> $line" if (! ($self->quiet() || $line =~ /\\\s*/));
		$self->do($line, $history);

		# Abort if requested
		$self->var('ntodo', 0) if ($self->abort());
	}
	$self->cmd_return();

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_return.pl
## ------------------------------------------------------------

sub cmd_return {
	my $self = shift;
	my $graph = shift || $self->graph();

	# Send update command to graph
	$graph->update();

	# Print follow file
	$self->cmd_print($graph, undef, 1)
		if ($self->{'viewer'});
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/cmd_save.pl
## ------------------------------------------------------------

sub cmd_save {
	my $self = shift;
	my $graph = shift;
	my $ftype = shift;
	my $fname = shift;

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


sub cmd_save_conll {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Calculate line numbers
	my $lines = [];
	my $line = 0;
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		my $input = $node->input();
		if (! $node->comment()) {
			$lines->[$i] = ++$line;
		} elsif ($input =~ /^<\/s>/) {
			$line = 0;
		}
	}

	# Open CONLL file
	open("CONLL", "> $file") 
		|| return error("cannot open file for writing: $file");

	# Write CONLL file line by line
	my $pos = $graph->layout($self, 'pos') || sub {return 0};
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);

		# Process non-comment nodes
		my $input = $node->input() || "??";
		if (! $node->comment()) {
			# ID
			my $ID = $lines->[$i];

			# FORM
			my $FORM = $input;
			$FORM =~ s/\s+//g;
			$FORM =~ s/&amp;/\&/g;

			# LEMMA
			my $LEMMA = $node->var('lemma') || "_";

			# CPOSTAG and POSTAG
			my $msd = $node->var($self->var('malt_feature_tag') || "msd") 
				|| "??";
			my $POSTAG = "$msd";
			$POSTAG =~ s/^(..).*$/$1/;
			$POSTAG = "I" if ($POSTAG =~ /^I/);
			$POSTAG = "U" if ($POSTAG =~ /^U/);
			my $CPOSTAG = "$POSTAG";
			$CPOSTAG =~ s/^(.).*/$1/g;
			$CPOSTAG = "SP" if ($CPOSTAG eq "S");
			$CPOSTAG = "RG" if ($CPOSTAG eq "R");

			
			# FEATS
			my $FEATS = conll_msd2features($CPOSTAG, substr($msd, 2)); 

			# HEAD AND DEPREL
			my $edges = [grep {! &$pos($graph, $_)} @{$node->in()}];
			my ($head, $type) = (0, "ROOT");
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
			my ($HEAD, $DEPREL) = ($head, $type);
			$HEAD = "0" if ($head eq "??");

			# PHEAD and PDEPREL
			my ($PHEAD, $PDEPREL) = ("_", "_");

			# Print head and type
			printf CONLL "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
				$ID, $FORM, "_",
				# ($LEMMA || "_"),
				($CPOSTAG || "_"), ($POSTAG || "_"), ($FEATS || "_"),
				($HEAD || "0"), ($DEPREL || "_"), $PHEAD, $PDEPREL;
		} elsif ($input =~ /^<\/s>/) {
			print CONLL "\n";
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
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		my $input = $node->input();
		if (! $node->comment()) {
			$lines->[$i] = ++$line;
		} elsif ($input =~ /^<\/s>/) {
			$line = 0;
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
		} elsif ($input =~ /^<\/s>/) {
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

	# Write MATCH file
	print MATCH (DTAG::Interpreter::dumper($self->{'matches'}) . "\n");

	# Close file
	close("MATCH");
	print "saved match-file $file\n" if (! $self->quiet());

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
	$self->cmd_resume(undef, 1);

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

	# Exit with error
	error("command cmd_show_align is unimplemented");
	return 1;

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
	$graph->include(scalar(%$include) ? $include : undef);
	$graph->exclude(scalar(%$exclude) ? $exclude : undef);
	$self->cmd_return($graph);

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
	my $opt = shift() . " ";

	# Clear styles
	my $sparent = $self;
	$sparent = $graph if ($graph && $opt =~ s/^-graph\s+//);
	if ($style =~ /^-clear\s*$/) {
		$sparent->{'styles'} = {};
		return 1;
	}

	# PostScript equivalents
	my $color = { 
		'black' 	=> '',
		'white' 	=> '1 setgray', 
		'gray'  	=> '0.5 setgray',
		'red'   	=> '1 0 0 setrgbcolor',
		'green' 	=> '0 1 0 setrgbcolor',
		'blue'  	=> '0 0 1 setrgbcolor',
		'cyan'  	=> '0 1 1 setrgbcolor',
		'magenta'	=> '1 0 1 setrgbcolor',
		'yellow' 	=> '1 1 0 setrgbcolor',
	};
	my $dash = {
		'none' 		=> '',
		'dash' 		=> '[4] 0 setdash',
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
##  auto-inserted from: Interpreter/cmd_text.pl
## ------------------------------------------------------------

sub cmd_text {
	my $self = shift;
	my $graph = shift;
	my $i1 = shift;
	my $i2 = shift;

	# Ensure i2 and i2 are defined
	$i1 = "=0" if (! defined($i1));
	$i2 = "=" . ($graph->size()-1) if (! defined($i2));

	# Print text
	print $graph->words($graph->pos2apos($i1), $graph->pos2apos($i2), " ")
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

	$graph->var('title', $text);
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
	print "variables: " . join(", ", @vars). "\n"
		if (! $self->quiet() || $print);

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
		. $N->xml($graph, 0) . "\n";
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

	# Specify new follow file
	++$viewer;
	my $fpsfile = "/tmp/dtag-$$-$viewer.ps";
	$self->fpsfile($fpsfile);
	$graph->fpsfile($fpsfile);

	# Update graph and viewer
	$self->{'viewer'} = 1;
	$self->cmd_return($graph);

	# Call viewer on $fpsfile
	my $viewcmd = "" . ($self->var('options')->{'viewer'} || 'gv $file &');
	$viewcmd =~ s/\$file/$fpsfile/g;
	#print "viewer=", $viewcmd;
	system($viewcmd);

	# Set follow file for current graph
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/do.pl
## ------------------------------------------------------------


sub do {
	my $self = shift;
	my $cmdstr = shift;
	my $history = shift;
	my $success = undef;
	my $graph = $self->graph();

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

		# Unix shell: ! $cmd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*!\s*(.*)$/);

		# UNIX commands recognized by DTAG: ls mkdir rmdir rm pwd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*((mkdir|rmdir|rm|pwd)(\s+.*)?)$/);
		$success = $self->cmd_shell("ls --color " . ($1 || ""))
			if ($cmd =~ /^\s*ls(\s+.*)?$/);

		# Adiff: adiff $file1 ... $fileN
		$success = $self->cmd_adiff($graph, $1)
			if ($cmd =~ /^\s*adiff\s+(.*)$/);

		# Adjuncts: adjuncts $comp1 $comp2 ....
		$success = $self->cmd_adjuncts($graph, $1) 
			if ($cmd =~ /^\s*adjuncts(\s+.*)?$/);

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

		# Change directory: cd $dir
		$success = $self->cmd_cd($1)
			if ($cmd =~ /^\s*cd\s+(.*)$/);

		# Clear: clear [-tag|-lex|-edges]
		$success = $self->cmd_clear($graph, $2) 
			if ($cmd =~ /^\s*clear( (-lex|-tag|-edges))?\s*$/);

		# Close: close
		$success = $self->cmd_close($graph, $2)
			if ($cmd =~ /^\s*close(\s+(-all))?\s*$/);

		# Comment: comment $pos $dtag_code
		$success = $self->cmd_comment($graph, $1, $2) 
			if ($cmd =~ /^\s*comment\s*([0-9]+)?\s+(.*)$/);

		# Complements: complements $comp1 $comp2 ....
		$success = $self->cmd_complements($graph, $1) 
			if ($cmd =~ /^\s*complements(\s+.*)?$/);

		# Compound: compound $node [segment|segment|...] 
		$success = $self->cmd_compound($graph, $1, $2)
			if ($cmd =~ /^\s*compound\s+([0-9]+)(.*)$/);
			
		# Corpus: corpus $files
		$success = $self->cmd_corpus($1) 
			if ($cmd =~ /^\s*corpus(\s+.*)?$/);

		# Delete node/edge/alignment edge: del $node [$etype $node]
		#	"del 12"
		#	"del 12 land 13"
		# 	"del a12"
		$success = $self->cmd_del($graph, $1, $2, $3) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') && (
				$cmd =~ /^\s*del\s+([+-]?[0-9]+)\s+(\S+)\s+([+-]?[0-9]+)\s*$/ ||
				$cmd =~ /^\s*del\s+([+-]?[0-9]+)\s*$/));
		$success = $self->cmd_del_align($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Alignment') &&
				$cmd =~ /^\s*del\s+([a-z]-?[0-9]+)\s*$/);
		if ($cmd =~ /^\s*del\s+-on\s*$/) {
			$success = 1;
			$graph->{'block_nodedel'} = 0;
		}
		if ($cmd =~ /^\s*del\s+-off\s*$/) {
			$success = 1;
			$graph->{'block_nodedel'} = 1;
		}
		
		# Diff: diff $file
		$success = $self->cmd_diff($graph, $2)
			if ($cmd =~ /^\s*diff\s*(\s(\S*))?\s*$/);

		# Delete incoming edges at node: edel $node
		$success = $self->cmd_edel($graph, $1) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') && 
				$cmd =~ /^\s*edel\s+([+-]?[0-9]+)\s*$/);

		# Edit node/edge: edit $node [$var[=$value]]
		#	"edit 12 gloss=him"
		#	"edit 12 in=12:subj|13:land"
		$success = $self->cmd_edit($graph, $1, $2) 
			if ($cmd =~ /^\s*edit\s+([+-]?[0-9]+)\s*(.*)\s*$/);

		# Exit: exit 
		#     : quit
		$success = $self->cmd_exit($graph)
			if ($cmd =~ /^\s*exit\s*$/ || $cmd =~ /^\s*quit\s*$/);

		# Find: find $pattern
		$success = $self->cmd_find($graph, $1) 
			if ($cmd =~ /^\s*find\s+(.*)$/);

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
		$success = $self->cmd_goto($1)
			if ($cmd =~ /^\s*goto\s+(.+)\s*$/);

		# Graph: graphs
		$success = $self->cmd_graphs($graph) 
			if ($cmd =~ /^\s*graphs\s*$/);

		# Help: help [$command]
		$success = $self->cmd_help($1) 
			if ($cmd =~ /^\s*help\s*(\S*)\s*$/);

		# Inalign: inalign 
		$success = $self->cmd_inalign($graph, $1, $2)
			if ($cmd =~ /^\s*inalign\s+([0-9+]+)\s+([0-9+]+)\s*$/);

		$success = $self->cmd_inline($graph, $1, $2) 
			if ($cmd =~ /^\s*inline\s+([0-9]+)\s+(.*)$/);

		# Inline: inline $pos $dtag_code
		$success = $self->cmd_inline($graph, $1, $2) 
			if ($cmd =~ /^\s*inline\s+([0-9]+)\s+(.*)$/);

		# Layout: layout $options
		$success = $self->cmd_layout($graph, $1)
			if ($cmd =~ /^\s*layout\s*(.*)\s*$/);

		# Lexicon: lexicon $name
		$success = $self->cmd_lexicon($1)
			if ($cmd =~ /^\s*lexicon\s+(\S*)\s*$/);

		# Load: load [-tag|-lex|-match] [-multi] [$file]
		$success = $self->cmd_load($graph, $2, $4, $3)
			if ($cmd =~ /^\s*load\s*((-lex|-tag|-atag|-match|-tiger|-malt|-conll|-emalt)\s+)?(-multi\s+)?(\S*)\s*$/);

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

		# Macro: macro $macro $cmd
		$success = $self->cmd_macro($1, $2) 
			if ($cmd =~ /^\s*macro\s+(\w+)\s+(.*)$/ ||
				$cmd =~ /^\s*macro\s+(\w+)\s*$/);

		# Macros: macros
		$success = $self->cmd_macros($1, $2) 
			if ($cmd =~ /^\s*macros\s*$/);

		# Maptags: maptags [-map $mapfile] $invar $outvar
		$success = $self->cmd_maptags($graph, $2, $3, $4)
			if ($cmd =~ /^\s*maptags(\s+-map\s+(\S+))?\s+(\S+)\s+(\S+)\s*$/);

		# Matches: matches
		$success = $self->cmd_matches($1)
			if ($cmd =~ /^\s*matches\s*(.*)$/);

		# Move node: move $pos1 $pos2
		$success = $self->cmd_move($graph, $1, $2)
			if ($cmd =~ /^\s*move\s+([0-9]+)\s+([0-9]+)\s*$/);

		# Multiedit: multiedit $node1-$node2 ...


		# New: new (create new graph)
		$success = $self->cmd_new()
			if ($cmd =~ /^\s*new\s*$/);

		# Next: next ... (shorthand for "goto next...")
		$success = $self->cmd_goto($cmd)
			if ($cmd =~ /^\s*next/);

		# Noedge: noedge $node
		$success = $self->cmd_noedge($graph, $1)
			if ($cmd =~ /^\s*noedge\s+([0-9]+)\s*$/);

		# Offset: offset [=+-]$offset
		$success = $self->cmd_offset($graph, $2, $3)
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
				&& $cmd =~ /^\s*offset(\s+([-+=])?([0-9]+))?\s*$/);
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
			if (($cmd =~ /^\s*option\s*([A-Za-z-]+)\s+(\S.*)$/)
				|| ($cmd =~ /^\s*option\s*([A-za-z-]+)\s*$/));

		# Offset and show: oshow $offset
		if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
				&& $cmd =~ /^\s*oshow(\s+([-+=])?([0-9]+))?\s*$/) {
			my ($sign, $offset) = ($2, $3);
			$success = $self->cmd_offset($graph, $sign, $offset);
			$success = $self->cmd_show($graph, " 0");
		}
		
	
		if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
			$cmd =~ /^\s*oshow(\s+[+-]?[0-9]+)\s*$/) {
			my $offset = $1;
		}

		# parse2dtag: parse2dtag $ifile $ofile
		$success = $self->cmd_parse2dtag($1, $2) 
			if ($cmd =~ /^\s*parse2dtag\s+(\S+)\s+(\S+)\s*$/);

		# Partag: partag $key
		$success = $self->cmd_partag($graph, $1)
			if ($cmd =~ /^\s*partag\s+(\S*)\s*$/);

		# Pause: pause
		$success = $self->cmd_pause()
			if ($cmd =~ /^\s*pause\s*$/);

		# Perl: perl [$expr]
		$success = $self->cmd_perl($4, $3, $1, $2)
			if ($cmd =~ /^\s*perl\s*(-v)?\s*(-corpus)?\s*(-file)?\s+(.*)\s*$/);

		# Prev: prev* (shorthand for "goto prev*")
		$success = $self->cmd_goto($cmd)
			if ($cmd =~ /^\s*prev/);

		# Print: print [$file]
		$success = $self->cmd_print($graph, $3, 0, $2)
			if ($cmd =~ /^\s*print\s*((-i|-p)\s+)*(\S*)\s*$/);

		# Parse step: pstep $number
		$success = $self->cmd_pstep($graph, $2)
			if ($cmd =~ /^\s*pstep(\s+([-+0-9]+))?\s*$/);

		# Relations: relations
		$success = $self->cmd_relations($graph, $2)
			if ($cmd =~ /^\s*relations\s*(\s+([^ ]*))?$/);

		# Resume: resume
		$success = $self->cmd_resume($2)
			if ($cmd =~ /^\s*resume(\s+([0-9]+))?\s*$/);

		# Save: save [$file]
		$success = $self->cmd_save($graph, $2, $3)
			if ($cmd =~ /^\s*save\s*((-lex|-tag|-atag|-alex|-xml|-malt|-match|-conll)\s+)?(\S*)\s*$/);

		# Script: script [$file]
		$success = $self->cmd_script($graph, $1)
			if ($cmd =~ /^\s*script\s*(\S*)\s*$/);

		# Server: server $directory
		$success = $self->cmd_server($1)
			if ($cmd =~ /^\s*server\s*(\S*)\s*$/);

		# Shell: shell $cmd
		$success = $self->cmd_shell($1)
			if ($cmd =~ /^\s*shell\s+(.*)$/);

		# Shift: shift $anode $offset
		$success = $self->cmd_shift($graph, $1, $2, $3)
			if ($cmd =~ /^\s*shift\s+([a-z])([0-9]+)\s+([-+]?[0-9]+)\s*$/);

		# Show: show [-component] $imin1[-$imax1] $imin2[-$imax2]
		# $success = $self->cmd_show($graph, $3, $5)
		if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
			$cmd =~ /^\s*show(\s+(-c(omponent)?|-y(ield)?))?((\s+[+-]?[0-9]+(-[0-9]+)?)*)\s*$/) {
			$success = $self->cmd_show($graph, $5, $2);
		}
		if (UNIVERSAL::isa($graph, 'DTAG::Alignment') &&
			$cmd =~ /^\s*show(\s+(-c(omponent)?|-y(ield)?))?((\s+[+-]?[a-z][0-9]+(-[a-z][0-9]+)?)*)\s*$/) {
			$success = $self->cmd_show_align($graph, $5, $2);
		}

		# Sleep: sleep $time
		$success = $self->cmd_sleep($1) 
			if ($cmd =~ /^\s*sleep\s+([0-9]*(\.[0-9]*)?)\s*$/);

		# Step: step
		$success = $self->cmd_resume(1)
			if ($cmd =~ /^\s*step\s*$/);

		# Style: style $id $options
		$success = $self->cmd_style($graph, $1, $3) 
			if ($cmd =~ /^\s*style\s+(\S+)(\s+(.+))?\s*$/);

		# Text: text $i1 $i2
		$success = $self->cmd_text($graph, $2, $4)
			if ($cmd =~ /^\s*text(\s+([+-=]?[0-9]+)(\s*\.\.\s*([+-=]?[0-9]+))?)?\s*$/);

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

		# Vars: vars [+$var[:$abbrev]] [-$var] ... 
		#	var +gloss:g +lexeme:x -glss
		$success = $self->cmd_vars($graph, $2) 
			if ($cmd =~ /^\s*vars(\s+)?(.*)?\s*$/);

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
		$success = $self->cmd_viewer($graph) 
			if ($cmd =~ /^\s*viewer\s*$/);

	# ---------- MACROS ----------

		# Macro
		if ($cmd =~ /^\s*(\w+)\s*$/ || $cmd =~ /^\s*(\w+)\s+(.*)\s*$/) {
			my ($x1, $x2) = ($1, $2);
			my $cmd = $self->{'macros'}{$x1};
			my $cmd2 = $cmd || "";
			if ($cmd && defined($x2) && $cmd =~ /{ARG}/) {
				$cmd2 =~ s/{ARG}/$x2/;
			} elsif ($cmd) {
				$cmd2 .=  " " . ($x2 || "");
			}
			$self->do($cmd2);
			$success = 1;
		}

	# ---------- SPECIAL COMMANDS THAT MUST GO AT THE END ----------


		# Add node: [node] [$pos] $input [$var=$value] ...
		#	"node Han t=XP g=He x=han123 m=han"
		#	" Han t=XP g=He x=han123 m=han"
		$success = $self->cmd_node($graph, $1, $2, $3) 
			if (UNIVERSAL::isa($graph, 'DTAG::Graph') &&
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
	return $self->var('fpsfile', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/gid2index.pl
## ------------------------------------------------------------

sub gid2index {
	my $self = shift;
	my $graphid = shift;

	# Find graph matching graph_id
	for (my $i = 0; $i < scalar(@{$self->{'graphs'}}); ++$i) {
		if ($self->{'graphs'}[$i]->graph_id() eq $graphid) {
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
	my $min = 1e100;
	grep {$min = $binding->{$_} if ((substr($_, 0, 1) eq '$')
		&& ($binding->{$_} < $min))} keys(%$binding);

	# Goto this position
	$self->cmd_show($graph, $min - $self->var('goto_context'));

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
	while ($line ne "exit" && $line ne "quit" 
			&& ($self->{'loop_count'} == 1 
				|| ($line ne "resume" && $line ne "abort"))) {
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
		$self->do($line);
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

	# Create empty graph
	$self->{'graphs'} = [DTAG::Graph->new()];
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
	print $message
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
	grep {$position = $binding->{$_} if ($binding->{$_} < $position)} @vars;
	$position = max(0, $position - ($self->var('goto_context') || 0));

	# Print match
	my $string = "";
	if (! $options->{'nomatch'}) {
		$string .=	sprintf '%sM%-3d match at %s:%s %s' . "\n",
				(($self->{'match'} || 0) == $match ? "*" : " "),
				$match,
				$file,
				$position,
				"(" . join(", ", @vars) . ")"
					. " = (" . join(", ", map {$binding->{$_}} (@vars)) . ")";
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
	$query_parser = new Parse::RecDescent ($query_grammar)
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
##  auto-inserted from: Interpreter/seconds2hhmmss.pl
## ------------------------------------------------------------

sub seconds2hhmmss {
	my $seconds = shift;

	return sprintf("%02i:%02i:%02i", 
		int($seconds / 3600), int($seconds / 60) % 60, $seconds % 60);
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

# 
# LICENSE
# Copyright (c) 2002-2003 Matthias Trautner Kromann <mtk@id.cbs.dk>
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
#     http://sf.net/projects/disgram/
#     http://www.id.cbs.dk/~mtk/dtag
# 
# Matthias Trautner Kromann
# mtk@id.cbs.dk
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

	# Parse range
	my $dmin = $range->[0] || "1";
	my $dmax = $range->[1] || "1";

	# Create object
    my $self = {'args' => [$node1, $node2, $dmin, $dmax, $dir]};
    bless($self, $class);
    return $self;
}

sub next {
    my $self = shift;
    my $graph = shift;
    my $bindings = shift;
    my $bind = shift;
    my $U = shift;

    # Decline answer if constraint is negated
    return undef if ($self->{'neg'});

    # Constraint is unnegated, and there is exactly one unbound
    # variable U and bound variable B.
	my $Barg = ($U eq $self->{'args'}[0]) ? 1 : 0;
    my $B = $self->{'args'}[$Barg];
    my $Bval = $self->var($bindings, $bind, $B);
	my $dmax = $self->{'args'}[3];

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

	my $n0 = $self->var($bindings, $bind, $self->{'args'}[0]);
	my $n1 = $self->var($bindings, $bind, $self->{'args'}[1]);
	my $dmin = $self->{'args'}[2] || 1;
	my $dmax = $self->{'args'}[3] || 1;

	my $dist = ($n1 - $n0) * ($self->{'args'}[4] || 1);
	#print "dist=$dist dmin=$dmin dmax=$dmax\n";
	return ($dist >= $dmin && $dist <= $dmax) ? 1 : 0;
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


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindEDGE.pl
## ------------------------------------------------------------

package FindEDGE;
@FindEDGE::ISA = qw(FindOp);

sub vars {
	return [0,2];
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;
	
	# Nodes
	my $in = $self->var($bindings, $bind, $self->{'args'}[0]);
	my $out = $self->var($bindings, $bind, $self->{'args'}[2]);
	my $etype = $self->{'args'}[1];

	# Check whether there exists an edge from node $in to $out with
	# type $etype
	my $node = $graph->node($in);
	return 0 if (! $node);
	return 1 
		if (grep {$_->out() == $out && $_->match($etype)} (@{$node->in()}));
	return 0;
}

sub next { 
    my $self = shift;
    my $graph = shift;
    my $bindings = shift;
    my $bind = shift;
    my $var = shift;

	# Exit if constraint is negated
	return undef if ($self->{'neg'});

	# Find suggested in and out node
	my $in = $self->var($bindings, $bind, $self->{'args'}[0]);
	my $out = $self->var($bindings, $bind, $self->{'args'}[2]);
	
	# Determine unbound variable
	my $etype = $self->{'args'}[1];
	if ($var eq $self->{'args'}[2]) {
		# Determine out-node from in-node: find in-node
		my $node = $graph->node($in);
		return 0 if (! $node);

		# Find matching edges
		my @edges = sort {$a->out() <=> $b->out()} 
			(grep {$_->match($etype) && $_->out() >= $out}  
				@{$node->in()});

		# Set $var, if there is a match
		if (@edges) {
			$bind->{$self->{'args'}[2]} = $edges[0]->out();
			return 1;
		} else {
			return 0;
		}
	} elsif ($var eq $self->{'args'}[0]) {
		# Determine in-node from out-node: find out-node
		my $node = $graph->node($out);
		return 0 if (! $node);

		# Find matching edges
		my @edges = sort {$a->in() <=> $b->in()} 
			(grep {$_->match($etype) && $_->in() >= $in}  
				@{$node->out()});

		# Set $var, if there is a match
		if (@edges) {
			$bind->{$self->{'args'}[0]} = $edges[0]->in();
			return 1;
		} else {
			return 0;
		}
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindEQ.pl
## ------------------------------------------------------------

package FindEQ;
@FindEQ::ISA = qw(FindOp);

sub vars {
	return [0,1];
}

sub next {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;
	my $U = shift;

	# Decline answer if constraint is negated, or there is not 
	# exactly one unbound variable
	return undef if ($self->{'neg'});

	# Constraint is unnegated, and there is exactly one unbound variable U
	# and bound variable B.
	my $B = $self->{'args'}[($U == $self->{'args'}[0]) ? 1 : 0];
	my $Bval = $self->var($bindings, $bind, $B);

	if ($bind->{$U} <= $Bval) {
		$bind->{$U} = $Bval;
		return 1;
	} else {
		return 0;
	}
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift || {};

	my $n1 = $self->var($bindings, $bind, $self->{'args'}[0]);
	my $n2 = $self->var($bindings, $bind, $self->{'args'}[1]);

	return ($n1 == $n2) ? 1 : 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindEXIST.pl
## ------------------------------------------------------------

package FindEXIST;
@FindEXIST::ISA = qw(FindOp);

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Find variable and condition
	my $var = $self->{'args'}[0];
	my $cond = $self->{'args'}[1];
	my $oldval = $bind->{$var};
	my $neg = $self->{'neg'} ? 1 : 0;

	# Fix bindings in $bind and $bindings
	my $newbindings = {};
	map {$newbindings->{$_} = $bindings->{$_}} keys(%$bindings);
	map {$newbindings->{$_} = $bind->{$_}} keys(%$bind);
	delete $newbindings->{$var};

	# Find all solutions to $cond with $newbindings
	my $solutions = $cond->solve($graph, 0, $newbindings); 

	# Check number of solutions in $solutions
	return @$solutions;
}

sub unbound {
	my $self = shift;
	my $unbound = shift;

	# Find unbound variables in argument
	$self->{'args'}[1]->unbound($unbound);

	# Remove variable from 
	delete $unbound->{$self->{'args'}[0]};

	# Return unbound variables
	return $unbound;
}

sub dnf {
	my $self = shift;
	my $var = $self->{'args'}[0];
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
		my $exist = FindEXIST->new($var, FindAND->new(@inner));
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


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindGT.pl
## ------------------------------------------------------------

package FindGT;
@FindGT::ISA = qw(FindOp);

sub vars {
	return [0,1];
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	my $n0 = $self->var($bindings, $bind, $self->{'args'}[0]);
	my $n1 = $self->var($bindings, $bind, $self->{'args'}[1]);

	return ($n0 > $n1) ? 1 : 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindINH.pl
## ------------------------------------------------------------

package FindINH;
@FindINH::ISA = qw(FindOp);

sub vars {
	return [0];
}

sub print {
	my $self = shift;
	my $type = ref($self);
	my $neg = ($self->{'neg'}) ? "!" : "";

	my $tname = DTAG::Interpreter::dumper($self->{'args'}[1]);
	$tname =~ s/^\$VAR1 = (.*);$/$1/;

	return "$neg$type(" . $self->{'args'}[0]  . ",$tname)";
}



## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindLT.pl
## ------------------------------------------------------------

package FindLT;
@FindLT::ISA = qw(FindOp);

sub vars {
	return [0,1];
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	my $n0 = $self->var($bindings, $bind, $self->{'args'}[0]);
	my $n1 = $self->var($bindings, $bind, $self->{'args'}[1]);

	return ($n0 < $n1) ? 1 : 0;
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


## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindOp.pl
## ------------------------------------------------------------

package FindOp;

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
	my $N = $graph->size();

	# Return if constraint has terminated, or graph size is zero
	return undef if ($N == 0 || $self->{'done'} || $#vars == -1);

	# Loop through all possible variable bindings
	my $result = {};
	while(1) {
		# Find first solution that does not precede current bindings
		my $bound = 0;
		while (! $bound) {
			# Find first legal binding that does not precede current
			# binding in the ordering
			for (my $v = $#vars; $v >= 0; --$v) {
				if ($bind->{$vars[$v]} >= $N) {
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
			my $next = $self->next($graph, $bindings, $bind, $vars[$#vars]);
			if (defined($next) && $next == 0) {
				# Custom binder exhausted all bindings of last variable
				$bind->{$vars[$#vars]} = $N;
				$bound = 0;
			} 
		}

		# Return undef if we have exhausted all bindings
		if ($bind->{$vars[0]} == $N) {
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
## Printing
##

sub print {
    my $self = shift;
    my $type = ref($self);
	my $neg = $self->{'neg'} ? "!" : "";

    # Print 
    return "$neg$type(" . join(",", 
		map {UNIVERSAL::isa($_, 'FindOp') ? $_->print() : "$_"} 
			@{$self->{'args'}}) . ")";
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

sub var {
	my $self = shift;
	my $bindings = shift;
	my $bind = shift;
	my $var = shift;

	return (exists $bind->{$var}) 
		? $bind->{$var} 
		: $bindings->{$var};
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

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindPATH.pl
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

sub print {
	my $self = shift;
	my $type = ref($self);
	my $neg = ($self->{'neg'}) ? "!" : "";

	my $path = DTAG::Interpreter::dumper($self->{'args'}[1]);
	$path =~ s/^\$VAR1 = (.*);$/$1/;

	return "$neg$type(" . $self->{'args'}[0]  . ",$path," 
		. $self->{'args'}[2] . ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Interpreter/FindOps/FindRE.pl
## ------------------------------------------------------------

package FindRE;
@FindRE::ISA = qw(FindOp);

sub vars {
	return [0];
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Variables
	my $node = $graph->node($self->var($bindings, $bind, $self->{'args'}[0]));
	my $var = $self->{'args'}[1];
	my $regexp = $self->{'args'}[2];

	# Check existence of node and return result
	return 0 if (! $node);
	my $value = $node->var($var);
	return 0 if (! defined($value)); 
	return eval("\$value =~ $regexp") ? 1 : 0;
}

1;

1;
