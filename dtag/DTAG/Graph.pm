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
##  auto-inserted from: Graph/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 DTAG::Graph

=head2 NAME

DTAG::Graph - DTAG dependency graphs

=head2 DESCRIPTION

DTAG::Graph - creating, manipulating and drawing dependency graphs

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Graph;
require DTAG::Interpreter;
require Encode;
use strict;

# Graph identifier
my $graph_id = 0;
my $DEFAULT_LOOKAHEAD = 50;

# PostScript 
my $pstrailer = {};
my $psheader = {};

sub readfile {
    my $file = shift;
    my $string = "";

    # Read file
    open(IFH, $file) 
		|| return DTAG::Interpreter::error("cannot read file $file in Graph->readfile\n" .
			"check that DTAGHOME is set correctly!");
    while (<IFH>) {
        $string .= $_;
    }
    close(IFH);

    # Return string
    return $string;
}

# PostScript prologues
my $src = $ENV{DTAGHOME} || "/opt/dtag/";
$psheader->{'arcs'}  = readfile("$src/arcs.header");
$pstrailer->{'arcs'} = readfile("$src/arcs.trailer");

# Default edges used in the treebank
my $etypes = 
	{
		'comp' => [],
		'adj' => [],
		'land' => [],
		'other' => []
	};


## ------------------------------------------------------------
##  auto-inserted from: Graph/AUTOLOAD.pl
## ------------------------------------------------------------

sub AUTOLOAD {
	use vars qw($AUTOLOAD);
	DTAG::Interpreter::error("non-existent method $AUTOLOAD")
		if ($AUTOLOAD !~ /::DESTROY$/);
	return undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/abbr2var.pl
## ------------------------------------------------------------

=item $graph->abbr2var($abbr) = $var

Find variable name $var corresponding to variable name abbreviation
$abbr.

=cut


sub abbr2var {
	my $self = shift;
	my $abbr = shift;

	# Variable names are returned unchanged
	return $abbr if (exists $self->vars()->{$abbr});

	# Find abbreviation
	foreach my $key (keys %{$self->vars()}) {
		my $value = $self->vars()->{$key};
		return $key if (($value || "") eq $abbr);
	}

	# Return 'estyles' unchanged
	return 'estyles' if ($abbr eq 'estyles');

	# Not found
	return undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/boundaries.pl
## ------------------------------------------------------------

=item $graph->boundaries($boundaries) = $boundaries

Get/set list of boundaries. ???

=cut

sub boundaries {
	my $self = shift;
	return $self->var('boundaries', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/cframe.pl
## ------------------------------------------------------------

sub cframe {
	my $self = shift;
	my $node = shift;
	my $N = $self->node($node);

	# Return cframe for node
    return join("", sort(
		map {ucfirst(lc($_->type()))}
			(grep {$self->is_complement($_)}
				@{$N->out()})));
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/child.pl
## ------------------------------------------------------------

=item $graph->child($node, $type) = [$child1, $child2, ...]

Return list of all child nodes of node $node which are connected to 
$node by an edge with type $type.

=cut


sub child {
	my $self = shift;
	my $node = shift;
	my $etype = shift;

	return [
		map {$_->in()} 
			grep {$_->type() eq $etype} @{$self->node($node)->out()}
	];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/child_edge.pl
## ------------------------------------------------------------

=item $graph->child_edge($node, $type) = [$edge, ...]

Return all child edges of node $node whose edge type equals $type.

=cut

sub child_edge {
	my $self = shift;
	my $node = shift;
	my $etype = shift;

	return [
		grep {$_->type() eq $etype} @{$self->node($node)->out()}
	];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/clear.pl
## ------------------------------------------------------------

=item $graph->clear()

Delete all nodes and edges from graph.

=cut

sub clear {
    my $self = shift;
    
    $self->nodes([]);
    #$self->vars({});
	$self->boundaries([]);
	$self->position(0);
	$self->input("");
	$self->var('imin', -1);
	$self->var('imax', -1);
}   


## ------------------------------------------------------------
##  auto-inserted from: Graph/clear_edges.pl
## ------------------------------------------------------------

sub clear_edges {
	my $self = shift;
	
	# Delete all edges in graph
	for (my $i = 0; $i < $self->size(); ++$i) {
		# Delete all edges at node
		my $node = $self->node($i);
		my $edges = $node ? [ @{$node->in()}, @{$node->out()} ] : [];
		foreach my $edge (@$edges) {
			$self->edge_del($edge);
		}
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/component.pl
## ------------------------------------------------------------

=item $graph->component($component, $node, $direction) = $component

Compute hash $component containing all nodes in the component
containing $node$. 

=cut

sub component {
	my $self = shift;
	my $node = shift;
	my $component = shift() || {};
	my $direction = shift() || 0;

	# Process all nodes
	if (defined($node) && ! defined($component->{$node})) {
		# Find node object
		my $nodeobj = $self->node($node);
		$component->{$node} = 1;

		# Skip node if it is a comment, a filler, or undefined
		return $component if ((! $nodeobj) || $nodeobj->comment());

		# Compute neighbouring nodes
		my @neighbours = ();
		push @neighbours, map {$_->out()} @{$nodeobj->in()};
		push @neighbours, map {$_->in()} @{$nodeobj->out()};
		
		# Follow links
		foreach my $n (@neighbours) {
			$self->component($n, $component, $direction);
		}
	}

	# Return component
	return $component;
}



## ------------------------------------------------------------
##  auto-inserted from: Graph/ddominates.pl
## ------------------------------------------------------------

=item $graph->ddominates($super, $node) = $boolean

Return true if $super dominates or equals $node in the deep tree.

=cut

sub ddominates {
	my $self = shift;
	my $super = shift;
	my $node = shift;

	# Succeed if $super equals $node
	return 1 if ($super == $node);
	
	# Succeed if $super ddominates governor of $node, fail if no
	# governor exists
	my $gov = $self->governor($node);
	return $gov ? $self->ddominates($super, $gov) : 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/deparse.pl
## ------------------------------------------------------------

sub deparse {
	my $self = shift;
	my $file = shift;

	# Retrieve all edges in the graph
	my $edges = [];
	$self->do_edges(sub {my $e = shift; my $L = shift; push @$edges, $e;}, 
		$edges); 
	
	# Sort edges
	$edges = [
		sort {(max($a->in(), $a->out()) <=> max($b->in(), $b->out()))
			|| (min($a->in(), $a->out()) <=> min($b->in(), $b->out()))}
		@$edges
	];

	# Print edges
	open(CMD, ">$file");
	my $n = 0;
	push @$edges, "";
	foreach my $e (@$edges) {
		# Print missing nodes
		my $nmax = $e ? max($e->in(), $e->out()) : $self->size() - 1;
		for (; $n <= $nmax; ++$n) {
			my $node = $self->node($n);
			if ($node->comment()) {
				print CMD "comment\n";
			} else {
				print CMD "node " . $node->input() . "\n";
			}
		}

		# Print edge
		print CMD "edge " . $e->in() . " " . $e->type() . " " . $e->out() . "\n"
			if ($e); 
	}
	close(CMD);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/depth.pl
## ------------------------------------------------------------

=item $graph->depths($depths, $node) = $depths

Compute depths hash $depths containing the depth of node $node and the
depth of all other nodes deeply dominating $node.

=cut

sub depths {
	my $self = shift;
	my $depths = shift || {};
	my $node = shift;
	
	# Find node object
	my $nodeobj = $self->node($node);

	# Skip node if it is a comment, a filler, or undefined, or if
	# its depth is defined already
	return $depths if ((! $nodeobj) 
		|| $nodeobj->comment() 
		|| defined($depths->{$node}));
	$depths->{$node} = [];

	# Find deep parent(s) of node
	my $maxdepth = 0;
	foreach my $e (@{$nodeobj->in()}) {
		if ($self->is_dependent($e)) {
			$self->depths($depths, $e->out());
			$maxdepth = max($maxdepth, $depths->{$e->out()} || 0);
		}
	}

	# Calculate depth
	$depths->{$node} = $maxdepth + 1;
		
	# Return depths
	return $depths;
}



## ------------------------------------------------------------
##  auto-inserted from: Graph/diffminus.pl
## ------------------------------------------------------------

=item $graph->diffminus($edge) = $boolean

Return true if $edge is a diff-edge which does not exist in $graph,
otherwise return false. 

=cut

sub diffminus {
	my $self = shift;
	my $edge = shift;
	my $unlabelled = shift;

	# Minus edges are always diff edges
	return 0 if (! $edge->var('diff'));

	# Minus edges must not exist as non-diff edges
	return (grep {(! $_->var('diff')) && $edge->eq($_, $unlabelled)} 
		@{$self->node($edge->in())->in()}) ?  0 : 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/diffplus.pl
## ------------------------------------------------------------

=item $graph->diffplus($edge) = $boolean

Return true if $edge is a non-diff edge which does not exist in the
associated diff $graph, otherwise return false. 

=cut

sub diffplus {
	my $self = shift;
	my $edge = shift;

	# Plus edges are always non-diff edges
	return 0 if ($edge->var('diff'));

	# Plus edges must not exist as diff edges
	return (grep {$_->var('diff') && $edge->eq($_)} 
		@{$self->node($edge->in())->in()}) ?  0 : 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/do_edges.pl
## ------------------------------------------------------------

=item $graph->do_edges($action, @args)

Call the procedure &$action($e, @args) for each edge $e in the graph. 

=cut

sub do_edges {
	my $self = shift;
	my $action = shift;

	# Process all edges
	my $n = $self->size();
	for (my $i = 0; $i < $n; ++$i) {
		# Find node and skip if comment
		my $node = $self->node($i);
		next() if $node->comment();

		foreach my $e (@{$node->in() || []}) {
			&$action($e, @{[@_]});
		}
	}

	# Return
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/dtag2cfg.pl
## ------------------------------------------------------------

sub dtag2cfg {
	my $self = shift;
	my $file = shift;
	my @vars = @_;

	my $s = "";

	sub cfgprint {
		my $node = shift;
		return join(" / ", shift, map {
			my $val = $node->var($_);
			$val = "" if (! defined($val));
			$val =~ s/'/\\'/g;
			"('" . ($val || "") . "')"} @_);
	}

	# Process each node in the graph
	my $sent = 0;
	for (my $n = 0; $n < $self->size(); ++$n) {
		my $node = $self->node($n);
		if (! $node->comment()) {
			# Print word
			$s .= "phrase($sent, " . cfgprint($node, $n, @vars) . ", ";

			# Find dependents
			my $left = [];
			my $right = [];
			foreach my $e (@{$node->out()}) {
				if ($self->is_dependent($e)) {
					if ($e->in() < $n) {
						push @$left, $e;
					} else {
						push @$right, $e;
					}
				}
			} 

			# Sort dependents by word order
			$left = [sort {$a->in() <=> $b->in()} @$left];
			$right = [sort {$a->in() <=> $b->in()} @$right];

			# Print dependents
			$s .= "[" . join(", ", map {"'" . $_->type() . "' = " 
				. cfgprint($self->node($_->in()), 
				$_->in(), @vars)} @$left) 
				. "], "; 
			$s .= "[" . join(", ", map {"'" . $_->type() . "' = " 
				. cfgprint($self->node($_->in()), 
				$_->in(), @vars)} @$right) 
				. "]).\n"; 
		} else {
			my $input = $node->input();
			++$sent if ($input =~ /<[sS]>/);
		}
	}

	open(OFH, "> $file"); 
	print OFH $s;
	close(OFH);
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/edge_add.pl
## ------------------------------------------------------------

=item $graph->edge_add($edge) = $edge

Add edge $edge to $graph.

=cut

sub edge_add {
	my $self = shift;
	my $edge = shift;
	my $unique = shift;

	# Find nodes
	my $nodein = $self->node($edge->in());
	my $nodeout = $self->node($edge->out());

	# Check legality of edge
	return DTAG::Interpreter::error("non-existent node: " . $edge->in()) 
		if (! defined($nodein));
	return DTAG::Interpreter::error("non-existent node: " . $edge->out()) 
		if (! defined($nodeout));
	
	# Check whether edge already exists
	my $exists = 0;
	foreach my $e (@{$nodein->in()}) {
		$exists = 1 if ($e->in() eq $edge->in()
			&& $e->out() eq $edge->out()
			&& $e->type() eq $edge->type());
	}

	# Add edge to nodes
	if (! ($unique && $exists)) {
		push @{$nodein->in()}, $edge;
		push @{$nodeout->out()}, $edge;
	}

	# Return
	return $edge;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/edge_del.pl
## ------------------------------------------------------------

=item $graph->edge_del($edge) = $edge

Remove edge $edge from $graph.

=cut

sub edge_del {
	my $graph = shift;
	my $edge = shift;
	my $nin  = $graph->node($edge->in());
	my $nout = $graph->node($edge->out());

	# Delete edge in in-node
	my $ein = $nin->in();
	for (my $i = 0; $i < scalar(@$ein); ) {
		if ($ein->[$i] == $edge) {
			splice(@$ein, $i, 1);
		} else {
			++ $i;
		}
	}

	# Delete edge in out-node
	my $eout = $nout->out();
	for (my $i = 0; $i < scalar(@$eout); ) {
		if ($eout->[$i] == $edge) {
			splice(@$eout, $i, 1);
		} else {
			++ $i;
		}
	}

	# Return edge
	return $edge;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/encoding.pl
## ------------------------------------------------------------

sub encoding {
	my $self = shift;
	return $self->var('encoding', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/etypes.pl
## ------------------------------------------------------------

=item $graph->etypes($etypes) = $etypes

Get/set edge type hash associated with graph.

=cut

sub etypes {
	my $self = shift;

	# Set etypes
	my $interpreter = $self->{'interpreter'};
	if (@_) {
		my $etypes0 = $self->var('etypes') 
			|| ($interpreter ? $interpreter->{'etypes'} : undef) || $etypes;
		my $etypes1 = shift;

		# Copy all missing etypes from $etypes0 to $etypes1
		foreach my $key (keys(%$etypes0)) {
			if (! exists $etypes1->{$key}) {
				$etypes1->{$key} = $etypes0->{$key};
			}
		}

		# Set new etypes
		$self->var('etypes', $etypes1);
	}

	# Return etypes
	return $self->var('etypes', @_) 
		|| ($interpreter ?  $interpreter->{'etypes'} : undef) 
		|| $etypes;
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/exclude.pl
## ------------------------------------------------------------

=item $graph->exclude($value) = $value

Get/set exclude hash $value

=cut

sub exclude {
	my $self = shift;

	# Write new value
	$self->{'_exclude'} = shift if (@_);

	# Return value
	return $self->{'_exclude'};
}
	

## ------------------------------------------------------------
##  auto-inserted from: Graph/file.pl
## ------------------------------------------------------------

=item $graph->file($file) = $file

Get/set file associated with graph.

=cut

sub file {
	my $self = shift;
		
	# Beautify file name by removing initial "./"
	if (@_) {
		my $s = shift;
		$s =~ s/^(\.\/)+//g;
		return $self->var('_file', $s);
	}

	# Return
	return $self->var('_file', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/format.pl
## ------------------------------------------------------------

=item $graph->format($var, $regexp) 

Set variable formatting for variable $var to filtering by regular expression $regexp. 

=cut

sub format {
	my $self = shift;
	my $var = shift;
	my $regexp = shift;

	# Process format specification if variable exists
	if (exists $self->{'vars'}{$var}) {
		if ($regexp) {
			# Add new formatting for $var
			$self->{'format'}{$var} = $regexp;
		} else {
			# Delete formatting for $var
			delete $self->{'format'}{$var};
		}
	} else {
		return DTAG::Interpreter::error("Variable $var does not exist!");
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/fpsfile.pl
## ------------------------------------------------------------

=item $graph->fpsfile($fpsfile) = $fpsfile

Get/set follow postscript file associated with graph.

=cut

sub fpsfile {
	my $self = shift;
	return $self->var('fpsfile', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/governor.pl
## ------------------------------------------------------------

=item $graph->governor($node) = $gov

Return governor $gov for node $node.

=cut

sub governor {
	my $self = shift;
	my $node = shift;

	# Find governor and landing site edges
	my $governor;
	foreach my $e (@{$self->node($node)->in()}) {
		if ($self->is_dependent($e)) {
			return $e->out();
		}
	}

	# No governor found
	return undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/graph_id.pl
## ------------------------------------------------------------

=item $graph->graph_id() = $id

Return graph ID associated with graph.

=cut

sub graph_id {
	my $self = shift;
	return '[G' . $self->{'graph_id'} . ']';
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/include.pl
## ------------------------------------------------------------

=item $graph->include($value) = $value

Get/set include hash $value

=cut

sub include {
	my $self = shift;

	# Write new value
	$self->{'_include'} = shift if (@_);

	# Return value
	return $self->{'_include'};
}
	

## ------------------------------------------------------------
##  auto-inserted from: Graph/input.pl
## ------------------------------------------------------------

=item $graph->input($input) = $input

Get/set input associated with graph.

=cut

sub input {
	my $self = shift;
	return $self->var('input', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/interpreter.pl
## ------------------------------------------------------------

sub interpreter {
	my $self = shift;
	return $self->{'interpreter'};
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/is_adjunct.pl
## ------------------------------------------------------------

sub is_adjunct {
	my ($self, $edge) = @_;
	
	# Return 1 if edge is an adjunct edge 
	my $type = "" . ((ref($edge) ? $edge->type() : $edge) || "");

	# Return 0 if edge is a landing edge
	return 0 if ($self->is_landing($edge));

	# Remove edge decorations
	$type =~ s/^://g;
	$type =~ s/^[Â¹Â²Â³^]+//g;
	$type =~ s/[Â¹Â²Â³^]+$//g;
	$type =~ s/\#$//g;
	$type =~ s/\/.*$//g;
	$type =~ s/\*//g;

	# See if reduced edge matches adjunct
	if (grep {$type eq ($_ || "")} @{$self->etypes()->{'adj'}}) {
		return 1;
	} elsif (grep {lc($type) eq ($_ || "")} @{$self->etypes()->{'adj'}}) {
		return 1;
	} elsif ($type =~ /^<([^:]*)(:(.*))?>$/) {
		my ($head, $tail) = ($1, $3 || "");
		my $return = 1;
		map {$self->is_dependent($_) || ($return = 0)} split(/:\./, $tail);
		return $self->is_adjunct($head) && $return;
	} elsif ($type =~ /^([^:]+):([^:]+)$/) {
		return $self->is_adjunct($1) && $self->is_dependent($2);
	}

	# Otherwise return 0
	return 0;
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/is_complement.pl
## ------------------------------------------------------------

sub is_complement {
	my ($self, $edge) = @_;
	
	# Return 1 if edge is a complement
	my $type = "" . ((ref($edge) ? $edge->type() : $edge) || "");

	# Return false if edge is a landing edge
	return 0 if ($self->is_landing($edge));

	# Remove edge decorations
	$type =~ s/^://g;
	$type =~ s/^[Â¹Â²Â³^]+//g;
	$type =~ s/[Â¹Â²Â³^]+$//g;
	$type =~ s/\#$//g;
    $type =~ s/\/.*$//g;
	$type =~ s/\*//g;

	# See if it is known
	if (grep {$type eq $_} @{$self->etypes()->{'comp'}}) {
		return 1;
	} elsif (grep {lc($type) eq $_} @{$self->etypes()->{'comp'}}) {
		return 1;
    } elsif ($type =~ /^<([^:]*)(:(.*))?>$/) {
        my ($head, $tail) = ($1, $3 || "");
        my $return = 1;
        map {$self->is_dependent($_) || ($return = 0)} split(/:\./, $tail);
        return $self->is_complement($head) && $return;
    } elsif ($type =~ /^([^:]+):([^:]+)$/) {
		return $self->is_complement($1) && $self->is_dependent($2);
	}

	# Otherwise return 0
	return 0;
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/is_dependent.pl
## ------------------------------------------------------------

sub is_dependent {
	my ($self, $edge) = @_;
	
	# Return 1 if edge is a complement
	return $self->is_complement($edge) || $self->is_adjunct($edge);
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/is_known_edge.pl
## ------------------------------------------------------------

sub is_known_edge {
	my ($self, $edge) = @_;
	
	# Return 1 if edge is a complement
	my $type = "" . ((ref($edge) ? $edge->type() : $edge) || "");
    $type =~ s/^://g;
    $type =~ s/^[Â¹Â²Â³^]+//g;
	$type =~ s/[Â¹Â²Â³^]+$//g;
    $type =~ s/\#$//g;

	# Normalize edge
	if ($self->is_dependent($type)) {
		return 1;
	} elsif ($type =~ /^\[(.*)\]$/) {
		return $self->is_dependent($1) ? 1 : 0;
	} elsif ($type =~ /^<(.*)>$/) {
		my $return = 1;
		map {$self->is_dependent($_) || ($return = 0)} split(/:/, $type);
		return $return;
	} elsif ($type =~ /:/) {
		my $return = 1;
		map {$self->is_dependent($_) || ($return = 0)} split(/:/, $type);
		return $return;
	} else {
		return (grep {$type eq $_} (map {@{$self->etypes()->{$_}}} 
				keys(%{$self->etypes()}))) 
			? 1 : 0;
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/is_landing.pl
## ------------------------------------------------------------

sub is_landing {
	my ($self, $edge) = @_;
	
	# Return 1 if edge is a landing edge
	my $type = ref($edge) ? $edge->type() : $edge;
	return 1 if (grep {$type eq $_} @{$self->etypes()->{'land'} || []});

	# Otherwise return 0
	return 0;
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/kwic.pl
## ------------------------------------------------------------

sub kwic {
	my $self = shift;
	my $edge = shift;
	return "";
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/labels.pl
## ------------------------------------------------------------

=item $graph->labels($interpreter, $maxlabels) = $labels

Compute set of labels contained in graph (omit label types with more
than $maxvalues different values). Afterwards, $labels is a hash with
the following structure:

	$labels = {	'_vars' => [$var1, ..., $varN],
				'_edges1' => [$edge, ...],
				'_edges2' => [$edge, ...],
				'$var1' => [$label, ...], 	# (if less than $maxlabels labels)
				'$var2' => undef,			# (if more than $maxlabels labels)
				...
			  }
=cut

sub labels {
	# Read parameters
	my $self = shift;
	my $interpreter = shift;
	my $maxlabels = shift || 500;

	# Variables
	my $vars = { };
	my $labels = { };
    my $pos = $self->layout($interpreter, 'pos') || sub {return 0};

	# Find possible variables to include in the graph, and compute
	# their position in the 'vars' regexp.
	my $regexps = [split(/\|/, 
		$self->layout($interpreter, 'vars') || "/stream:.*/|msd|gloss")];
	foreach my $var (keys(%{$self->vars()})) {
		my $m = regexp_match($regexps, $var);
		$vars->{$var} = $m if ($m);
	}

	# Sort labels and initialize $labels hash
	my @sorted = sort {($vars->{$a} <=> $vars->{$b}) || ($a cmp $b)} 
					keys(%$vars);
	map {$labels->{$_} = {}} @sorted;
	
	# Compute possible label values (if fewer than $maxlabels)
	my $size = $self->size();
	for (my $i = 0; $i < $size; ++$i) {
		my $node = $self->node($i);
		if ($node && ! $node->comment()) {
			# Add edge labels to list
			foreach my $e (@{$node->in()}) {
				if (&$pos($self, $e)) {
					# Bottom edge
					$labels->{'_edges2'}{$e->type()} = 1; 
				} else {
					# Top edge
					$labels->{'_edges1'}{$e->type()} = 1; 
				}
			}

			# Add variable values to list
			foreach my $v (@sorted) {
				if (defined($labels->{$v})) {
					# Store variable value
					$labels->{$v}{$self->reformat($interpreter,
						$v, $node->var($v), $self, $i)} = 1;

					# Undefine if number of values exceeds $maxlabels
					$labels->{$v} = undef
						if (scalar(keys(%{$labels->{$v}})) > $maxlabels);
				}
			}
		}

		# Abort if requested
		last() if ($interpreter->abort());
	}

	# Compute new labels hash 
	map {$labels->{$_} = [sort(keys(%{$labels->{$_}}))]} keys(%$labels);
	$labels->{'_vars'} = [@sorted];

	# Return labels hash
	return $labels;
}




## ------------------------------------------------------------
##  auto-inserted from: Graph/lang.pl
## ------------------------------------------------------------

sub lang {
	my $self = shift;
	my $node = shift;
	my $N = $self->node($node);
	return (defined $N ? $N->var('_lang') : "")
		|| $self->var('lang')
		|| "";
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/layout.pl
## ------------------------------------------------------------

=item $graph->layout($default, $var) = $layout

Return layout value $layout for variable $var, retrieving the layout
value from $default if it isn't defined by $graph.

=cut

sub layout {
	my $self = shift;
	my $default = shift;
	my $var = shift;
	my $layout = $self->{'layout'} ? $self->{'layout'}{$var} : undef;
	return $layout || $default ->{'layout'}{$var};
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/lexicon.pl
## ------------------------------------------------------------

=item $self->lexicon($lexicon) = $lexicon

Get/set lexicon associated with graph.

=cut

sub lexicon {
	my $self = shift;
	$self->{'lexicon'} = shift if (@_);
	return $self->{'lexicon'} || DTAG::Interpreter->interpreter()->lexicon();
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/lexicon_stream.pl
## ------------------------------------------------------------

=item $self->lexicon_stream($stream, $lexicon) = $lexicon

Get/set lexicon associated with stream $stream in graph, using
$graph->lexicon() as the default.

=cut

sub lexicon_stream {
	my $self = shift;
	my $stream = shift || 0;

	$self->{'lexstream'}{$stream} = shift if (@_);
	return $self->{'lexstream'}{$stream} || $self->lexicon();
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/lookahead.pl
## ------------------------------------------------------------

=item $graph->lookahead($lookahead) = $lookahead

Get/set lookahead associated with graph.

=cut

sub lookahead {
	my $self = shift;
	$self->{'lookahead'} = shift if (@_);
	return $self->{'lookahead'} || $DEFAULT_LOOKAHEAD;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/lookup.pl
## ------------------------------------------------------------

=item $graph->lookup($time, $stream) = $lexemes

Return list of all lexemes starting at time $time in input stream
$stream.

=cut

sub lookup {
	my $self = shift;
	my $time = shift;
	my $stream = shift;

	# Find first node in graph with time0 >= $time, using binary
	# search (we assume nodes in the graph are ordered by increasing time0)
	my $imin = 0;
	my $imax = max(0, $self->size() - 1);
	while ($imin != $imax) {
		my $imid = int(($imin + $imax) / 2 - 0.25);	# round down
		my $time0 = $self->time0($imid);
		if ($time0 < $time) {
			$imin = min($imid + 1, $imax);
		} else {
			$imax = max($imid, $imin);
		} 
	}

	# Apply lexicon to all nodes with time0 = $time
	my $lexemes = [];
	my $node = $imin;
	my $nodeobj;
	while (defined($nodeobj = $self->node($node)) 
			&& $self->time0($node) == $time) {
		# Find node input, stream, and lexicon
		my $input = $nodeobj->input();
		my $nstream = $nodeobj->stream();

		# Process nodes from the right stream
		if ((! defined($stream)) || $nstream eq $stream) {	
			my $lexicon = $self->lexicon_stream($stream);

			# Fail if no lexicon
			if (! $lexicon) {
				DTAG::Interpreter::error("No lexicon specified in Graph->lookup"
					. " (node=$node)\n");
				last();
			}

			# Find all matching lexical entries
			my $list = $lexicon->lookup_word(lc($input));
			foreach my $typename (@$list) {
				my $lexeme = Lexeme->new();
				$lexeme->time0($self->time0($node));
				$lexeme->time1($self->time1($node));
				$lexeme->typename($typename);
				$lexeme->stream($nstream);
				push @$lexemes, $lexeme;
			}
		}

		# Look at next node
		++$node;
	}

	# Return found lexemes
	return $lexemes;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/lsite.pl
## ------------------------------------------------------------

=item $graph->lsite($node) = $lsite

Return landing site for node $node.

=cut

sub lsite {
	my $self = shift;
	my $node = shift;
	my @surf = @{$self->etypes()->{'surf'}};

	# Find governor and landing site edges
	my $lsite;
	foreach my $e (@{$self->node($node)->in()}) {
		if (grep {$e->type() eq $_} @surf) {
			return $e->out();
		}
	}

	# No landing site found: return governor
	return undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/lsite_auto.pl
## ------------------------------------------------------------

=item $graph->lsite_auto($node) = $lsite

Return auto-generated landing site for node $node (the lowest
dominating node in the deep tree which has $node in its continuous
surface yield).

=cut


sub lsite_auto {
	my $self = shift;
	my $node = shift;
	my $lsite = $self->governor($node);

    while ($lsite && ! $self->sdominates($lsite, $node)) {
		$lsite = governor($self, $lsite);
	}
	return $lsite;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/lsite_default.pl
## ------------------------------------------------------------

=item $graph->lsite_default($node) = $lsite

Return default landing site for node $node (defined as the parent
node with edge type "land", or, if no such node exists, the governor
of $node). 

=cut

sub lsite_default {
	my $self = shift;
	my $node = shift;
	my @surf = @{$self->etypes()->{'surf'}};

	# Find governor and landing site edges
	my $lsite;
	foreach my $e (@{$self->node($node)->in()}) {
		if (grep {$e->type() eq $_} @surf) {
			return $e->out();
		}
	}

	# No landing site found: return governor
	return $self->governor($node);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/matches.pl
## ------------------------------------------------------------

=item $graph->matches($interpreter)

Return hash containing all nodes in $graph which the interpreter
$interpreter has marked as matches from a "find" query. 

=cut

sub matches {
	my $self = shift;
	my $inter = shift;

	# Find matched nodes in interpreter
	my $match = {};
	if ($inter) {
		# Find list of matches
		my $m = 
			$inter->{'matches'}{$self->graph_id() || ""}
			|| $inter->{'matches'}{$self->file() || ""}
			|| [];
		my $irm = $inter->{'replace_match'};
		my $irmf = $irm ? $irm->{$self} : undef;
		$m = $irmf if ($irmf);

		# Process list of matches
		foreach my $b (@$m) {
			map {$match->{$b->{$_}} = 1} keys(%$b);
		}
	}

	# Return hash with matched nodes
	return $match;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/max.pl
## ------------------------------------------------------------

=item max($a, $b) = $max

Return the maximum of $a and $b.

=cut

sub max {
	return ($_[0] > $_[1]) ? $_[0] : $_[1];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/min.pl
## ------------------------------------------------------------

=item min($a, $b) = $min

Return the minimum of $a and $b.

=cut

sub min {
	return ($_[0] < $_[1]) ? $_[0] : $_[1];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/mtime.pl
## ------------------------------------------------------------

=item $graph->mtime($set) = $mtime

Get/set modification time of graph. If $set is defined, $mtime is set
to the current time.

=cut

sub mtime {
	my $self = shift;
	if (@_) {
		$self->{'mtime'} = shift() ? time() : undef;
	}
	return $self->{'mtime'};
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/new.pl
## ------------------------------------------------------------

=item Graph->new() = $graph

Create new Graph object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $interpreter = shift;
	my $class = ref($proto) || $proto;


	# Create self: 
	my $self = { 
		'nodes' => [], 
		'boundaries' => [], 
		'vars' => {}, 
		'format' => {},
		'imin' => -1,
		'imax' => -1,
		'graph_id' => ++$graph_id,
		'lexstream' => {},
		'inalign' => {},
		'interpreter' => $interpreter
	};

	# Specify class for new object
	bless ($self, $class);
	$self->clear();

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: Graph/next_lexeme.pl
## ------------------------------------------------------------

=item $graph->next_lexeme($time) = $lexeme

Return first lexeme after time position $time.

=cut

sub next_lexeme {
	my $self = shift;
	my $time = shift;
	my $next = $time + 1;
	return $self->node($next) ? $next : undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/next_noncomment_node.pl
## ------------------------------------------------------------

sub next_noncomment_node {
	my $graph = shift;
	my $node = max(0, shift || 0);
	my $n = shift || 1;

	# Search for next non-comment node
	my $next = undef;
	while ($node < $graph->size() && $n > 0) {
		if (! $graph->node($node)->comment()) {
			--$n;
			$next = $node if ($n == 0);
		}
		++$node;
	}

	# Return non-comment node
	return $next;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/node.pl
## ------------------------------------------------------------

=item $graph->node($pos) = $node

Return node $node at node position $pos.

=cut

sub node {
	my $self = shift;
	my $i = shift;

	return (defined($i) && $i >= 0) ? $self->nodes()->[$i] : undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/node_add.pl
## ------------------------------------------------------------

=item $graph->node_add($pos, $node) = $node

Insert node $node at position $pos in graph.

=cut

sub node_add {
	my $self = shift;
	my $pos = shift;
	my $node = shift;

	# Check that $pos is a legal value
	my $nodes = $self->size();
	$pos = $nodes if ((! defined($pos) || ! length($pos)) 
		|| ($pos < 0) || ($pos > $nodes));

	# Insert new word into word list
	splice(@{$self->nodes()}, $pos, 0, $node);

	# Update edges in words at or after $pos
	for (my $i = $pos; $i <= $nodes; ++$i) {
		my $n = $self->node($i);
		if (! defined($n)) {
			print "ERROR: undefined node $i\n";
			return;
		}

		# Process in-edges
		foreach my $e (@{$n->in()}) {
			if ($e->in() > $e->out()) {
				$e->in($e->in() + 1);
				$e->out($e->out() + 1) if ($e->out() >= $pos);
				#print "[increment in-edge in $i]\n";
			}
		}

		# Process out-edges
		foreach my $e (@{$n->out()}) {
			if ($e->out() > $e->in()) {
				$e->out($e->out() + 1);
				$e->in($e->in() + 1) if ($e->in() >= $pos);
				#print "[increment out-edge in $i]\n";
			}
		}
	}

	# Return
	return $node;
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/nodes.pl
## ------------------------------------------------------------

=item $graph->nodes($nodes) = $nodes

Get/set node list $nodes.

=cut

sub nodes {
	my $self = shift;
	return $self->var('nodes', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/offset.pl
## ------------------------------------------------------------

=item $graph->offset($offset) = $offset

Get/set offset associated with graph (number for first line of file).

=cut

sub offset {
	my $self = shift;
	return $self->var('_offset', @_) || 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/parent.pl
## ------------------------------------------------------------

=item $graph->parent($node, $etype) = $nodes

Return list $nodes of all parent nodes for node $node with edge type
$etype.

=cut


sub parent {
	my $self = shift;
	my $node = shift;
	my $etype = shift;

	return [
		map {$_->out()} 
			grep {$_->type() eq $etype} @{$self->node($node)->in()}
	];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/parent_edge.pl
## ------------------------------------------------------------

=item $graph->parent_edge($node, $etype) = $edges

Return list $edges of all parent edges for node $node with edge type
$etype.

=cut

sub parent_edge {
	my $self = shift;
	my $node = shift;
	my $etype = shift;

	return [
		grep {$_->type() eq $etype} @{$self->node($node)->in()}
	];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/parents.pl
## ------------------------------------------------------------

=item $graph->parents($node) = [$governor, $lsite]

Return governor and landing site for node $node.

=cut

sub parents {
	my $self = shift;
	my $node = shift;

	# Find governor and landing site edges
	my $lsite;
	my $governor;
	foreach my $e (@{$self->node($node)->in()}) {
		if ($self->is_dependent($e)) {
			$governor = $e->out();
		}
		if ($self->is_landing($e)) {
			$lsite = $e->out();
		}
	}

	# Set landing site to governor, if undefined
	$lsite = $governor if (! defined($lsite));

	# Return governor and landing site
	return [$governor, $lsite];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/parse.pl
## ------------------------------------------------------------

=item $graph->parse($parse) = $parse

Get/set parse object associated with graph.

=cut

sub parse {
	my $self = shift;
	$self->{'parse'} = shift if (@_);
	return $self->{'parse'};
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/pos2apos.pl
## ------------------------------------------------------------

sub pos2apos {
	my $self = shift;
	my $pos = shift;

	# Decompose position
	$pos =~ /^([+=-])?([0-9]+)$/;
	my $o = $1 || "+";
	my $n = $2 || "0";

	# Calculate absolute position
	if ($o eq "+") {
		return $self->offset() + $n;
	} elsif ($o eq "-") {
		return $self->offset() - $n;
	} elsif ($o eq "=") {
		return $n;
	} else {
		DTAG::Interpreter::error("Invalid argument $pos to Graph->pos2apos()");
		return undef;
	}
}	

## ------------------------------------------------------------
##  auto-inserted from: Graph/position.pl
## ------------------------------------------------------------

=item $graph->position($pos) = $pos

Get/set position of graph. ???

=cut

sub position {
	my $self = shift;
	return $self->var('position', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/postscript.pl
## ------------------------------------------------------------

=item $graph->postscript() = $postscript

Return PostScript representation $postscript for graph.

=cut


sub postscript {
	my $self = shift;
	my $interpreter = shift;

	# Variables
	my $N = 0;					# number of words
	my $E = 0;					# number of edges
	my $nodes = { };			# nodes in graph
	my $streams = { };			# streams in graph
	my $labels = { };			# labels in graph and their position
	my $ps = "% Words and edges\n";
	$self->{'psstyles'} = {};	# reset compiled styles
	$self->{'psstyleno'} = 0;	# number of psstyles

	# Find hash with matched nodes
	my $matches = $self->matches($interpreter);

	# Find layout values, with defaults
	my $sub0 = sub { return 0 };
	my $subL = sub { return [] };
	my $stream = $self->layout($interpreter, 'stream') || $sub0;
	my $nstyles = $self->layout($interpreter, 'nstyles') || $subL;
	my $estyles = $self->layout($interpreter, 'estyles') || $subL;
	my $nhide = $self->layout($interpreter, 'nhide') || $sub0;
	my $ehide = $self->layout($interpreter, 'ehide') || $sub0;
	my $pos = $self->layout($interpreter, 'pos') || $sub0;

	# Create alignments 
	my $forced_edget = {};
	my $forced_edgeb = {};
	my $alignments = "% Alignments\n/alignments [\n";
	foreach my $inalign (sort(keys(%{$self->{'inalign'}}))) {
		# Interpret $inalign edge
		my ($from, $to) = split(/\s+/, $inalign);
		my @fromlist = split(/\+/, $from);
		my @tolist = split(/\+/, $to);

		# Create PostScript code
		$alignments .= "\t[" 
			. ($#fromlist == 0 ? $fromlist[0] : 
				"[" . join(" ", @fromlist) . "]")
			. " "
			. ($#tolist == 0 ? $tolist[0] : 
				"[" . join(" ", @tolist) . "]") 
			. "]\n";

		# From nodes have forced edget edges, to nodes have forced edgeb edges
		map {$forced_edget->{$_} = 1} @fromlist;
		map {$forced_edgeb->{$_} = 1} @tolist;
	}
	$alignments .= "] def\n\n";


	# Find possible variables to include in the graph
	my $regexps = [split(/\|/, 
		$self->layout($interpreter, 'vars') || "/stream:.*/|msd|gloss")];
	my @newvars = ();
	foreach my $var (keys(%{$self->vars()})) {
		push @newvars, $var
			if (regexp_match($regexps, $var));
	}

	# Find nodes, streams, and variables to include in graph using
	# nhide, $imin, and $imax, and number words consecutively from 0
	my $imin = max($self->var('imin'), 0);
	my $imax = min($self->var('imax'), $self->size()-1);
	$imax = $self->size() if ($imax < 0);
	for (my $i = $imin; $i <= $imax; ++$i) {
		my $node = $self->node($i);
		if ($self->node($i) && (! &$nhide($self, $self->node($i)))
			&& ((! defined($self->include())) || $self->include()->{$i})
			&& ((! defined($self->exclude())) || ! $self->exclude()->{$i})) {
			# Node $i is printed in the graph
			$nodes->{$i} = $N++;

			# Find stream associated with word
			$streams->{&$stream($self, $node) || 0} = 1;

			# Try to find values for missing newvars
			if (@newvars) {
				my @newvars2 = ();
				foreach my $var (@newvars) {
					if (defined($node->var($var))) {
						$labels->{$var} = regexp_match($regexps, $var);
					} else {
						push @newvars2, $var;
					}
				}
				@newvars = @newvars2;
			}
		}

		# Abort if requested
		last() if ($interpreter->abort());
	}

	# Exit if no nodes
	return undef if (! $N);

	# Add position and streams to possible labels
	my $match = regexp_match($regexps, '_position');
	$labels->{'_position'} = $match if ($match);
	foreach my $s (keys(%$streams)) {
		$match = regexp_match($regexps, "stream:$s");
		$labels->{"stream:$s"} = $match if ($match);
	}

	# Sort labels and check that there is at least one label
	my $L = 0;
	my @sorted = ();
	foreach my $l (sort {($labels->{$a} <=> $labels->{$b}) 
							|| ($a cmp $b)} keys(%$labels)) {
		$labels->{$l} = $L++;
		push @sorted, $l;
	}
	return DTAG::Interpreter::error("illegal number of variables: $L") 
		if ($L == 0);

	# Print words and edges
	foreach my $n (sort {$a <=> $b} keys(%$nodes)) {
		my $node = $self->node($n);

		# Print word
		my $s = &$stream($self, $node) || 0;
		my $val = "";
		foreach my $lbl (@sorted) {
			# Find value
			if ($lbl =~ /^stream:.*$/) {
				$val = ($lbl eq "stream:$s") 
					?  $node->input() : "";
			} elsif ($lbl eq '_position') {
				my $rpos = $n - $self->offset();
				$val = ($self->offset() && $rpos >= 0) 
					? "+$rpos" : "$rpos";
			} else {
				$val = $self->reformat($interpreter, $lbl, $node->var($lbl),
					$self, $n);
			}

			# Find layout ID
			my $stylelist = &$nstyles($self, $node, $lbl);
			unshift @$stylelist, 'match' if ($matches->{$n});
			my $layout = $self->psstyle($interpreter, 'label',  $stylelist);

			# Produce PostScript string
			$ps .= psstr($val) . $layout . " ";
		}
		$ps .= "word\n";

		# Print in-edges of word, if out-word is in $nodes
		my $bottom = 0;
		foreach my $e (@{$node->in()}) {
			if (defined($nodes->{$e->out()}) && ! (&$ehide($self, $e))) {
				# Calculate edge layouts
				my $type = $e->type();
				my $alayout = $self->psstyle($interpreter, 'arc', 
					&$estyles($self, $e));
				my $llayout = $self->psstyle($interpreter, 'arclabel', 
					&$estyles($self, $e));
				$llayout = 0 if ($alayout && ! $llayout);

				$ps .= $nodes->{$e->in()} . " " 
					 . $nodes->{$e->out()} . " "
					 . psstr($e->type())
					 . $llayout . $alayout . " ";

				# Find out whether the edge is top or bottom
				if (&$pos($self, $e)) {
					# Bottom edge (unless forced top)
					$ps .= $forced_edget->{$e->in()} ? "edget\n" : "edgeb\n";
				} else {
					# Top edge (unless forced bottom)
					$ps .= $forced_edgeb->{$e->in()} ? "edgeb\n" : "edget\n";
				} 

				# Increment edge counter
				++$E;
			}
		}

		# Abort if requested
		last() if ($interpreter->abort());
	}

	# Produce PostScript styles
	my $titlestyle = $self->psstyle($interpreter, 'label',  ['title']) || 0;
	my $pslayout = "/formats [\n";
	foreach my $pstyle (sort 
			{$self->{'psstyles'}{$a} <=> $self->{'psstyles'}{$b}}
			keys(%{$self->{'psstyles'}})) {
		$pslayout .= "\t{$pstyle}\n";
	}
	$pslayout .= "] def\n\n";

	# Find prologue
	my $pssetup = $self->layout($interpreter, 'pssetup') || "";


	# Print setup
	my $title = $self->var('title') || " ";
	$title =~ s/\(/\\\(/g;
	$title =~ s/\)/\\\)/g;
	$ps = $psheader->{'arcs'} 
		. "% General setup\n" 
		. $pssetup . "\n\n"
		. "% Graph setup\n" 
		. "/title {($title) $titlestyle} def\n\n"
		. "$L $N $E setup\n" 
		. $pslayout
		. $ps . "\n"
		. $alignments 
		. $pstrailer->{'arcs'};

	# Return string
	return Encode::encode("iso-8859-1", $ps);
}

sub regexp_match {
	my $regexps = shift;
	my $s = shift;

	my $i = 0;
	foreach my $regexp (@$regexps) {
		++$i;
		if ($regexp =~ /^\/.*\/$/) {
			return $i if (eval("\$s =~ $regexp"));
		} else {
			return $i if ($s eq $regexp);
		}
	}
	return 0;
}

sub psstr {
	my $input = shift;
	$input = "" if (! defined($input));
	$input =~ s/\)/\\\)/;
	$input =~ s/\(/\\\(/;
	$input =~ s/\&gt;/>/;
	$input =~ s/\&lt;/</;

	return "(" . 
		$input
		#	Encode::encode("iso-8859-1", $input) 
		. ")";
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/print.pl
## ------------------------------------------------------------

=item $graph->print() = $string

Return simple string representation for graph (used for debugging
only).

=cut

sub print {
	my $self = shift;

	return "graph(" 
		. "nodes=[" . join(",", @{$self->nodes()}) . "]"
		. " input="  . $self->input()
		. " position=" . $self->position()
		. " boundaries=[" . join(",", @{$self->boundaries()}) . "]"
		. " vars=[" . join(",", 
			map {"$_=" . $self->vars()->{$_}} sort(keys(%{$self->vars()}))) 
				. "]"
		. ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/print_graph.pl
## ------------------------------------------------------------

sub print_graph {
	my $graph = shift;
	my $id = shift;
	my $index = shift;
	
	return sprintf '%sG%-3d file=%s %s' . "\n" . '      %s' . "\n",
		($index - 1 == ($id || 0) ? '*' : ' '),
		$index, 
		($graph->file() || '*untitled*'),
		($graph->mtime() ? 'modified ' : 'unmodified'),
		'"' . $graph->text(' ', 60) . '"';
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/print_osdt.pl
## ------------------------------------------------------------

sub print_osdt {
	my $self = shift;
	my $prefix = shift;
	my $viewcount = shift || 0;
	my $nodecount = shift || 0;
	my $nodes2id = shift;
	#$nodes2id = {} if (!defined($nodes2id));

	# Write OSDT header
	my $nodes = "LAYER" . $viewcount++ . " \"$prefix" . "words\"";
	my $deps = "LAYER" . $viewcount++ . " \"$prefix" . "dependency edges\" 0=\"relation\"\n";
	my $sec = "LAYER" . $viewcount++ . " \"$prefix" . "other edges\" 0=\"relation\"\n";

	# Find node features
	my $vars = ["string", sort(keys(%{$self->vars()}))];
	my $cnt = 0;
	foreach my $var (@$vars) {
		my $cleaned = "" . $var;
		$cleaned =~ s/	/\&\#11;/g;
		$nodes .= " " . $cnt++ . "=\"" . $cleaned . "\"";
	}
	$nodes .= "\n";

	# Write OSDT file line by line
	for (my $i = 0; $i < $self->size(); ++$i) {
		my $N = $self->node($i);
		if (! $N->comment()) {
			$nodes2id->{$i} = $nodecount++;
			$nodes .= "  NODE" . $nodes2id->{$i};
			for (my $i = 0; $i <= $#$vars; ++$i) {
				my $value = ($i == 0) ? $N->input() : $N->var($vars->[$i]);
				if (defined($value)) {
					$value = "" . $value;
					$value =~ s/"/\&quot;/g;
					$nodes .= " $i=\"$value\"";
				}
			}
			$nodes .= "\n";
		}
	}

	# Process edges
	for (my $i = 0; $i < $self->size(); ++$i) {
		my $N = $self->node($i);
		if (! $N->comment()) {
			# Process in-edges at node
			foreach my $e (@{$N->in()}) {
				my $nin = $nodes2id->{$e->in()};
				my $nout = $nodes2id->{$e->out()};
				my $type = $e->type();
				if ($self->is_dependent($e)) {
					# Primary in-edge
					$deps .= "  EDGE $nin<$nout 0=\"$type\"\n";
				} else {
					# Other edge
					$sec .= "  EDGE $nin<$nout 0=\"$type\"\n";
				}
			}
		}
	}

	# Save view and node count in nodes2id
	$nodes2id->{'_views'} = $viewcount;
	$nodes2id->{'_nodes'} = $nodecount;

	# Return
	return $nodes . $deps . $sec;
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/print_tag.pl
## ------------------------------------------------------------

sub print_tag {
	my $graph = shift;

	# Write XML file line by line
	my $s = "";
	foreach (my $i = 0; $i < $graph->size(); ++ $i) {
		my $N = $graph->node($i);
		$s .= ($N->comment() 
				? ($N->input() . "\n")
				: ($N->xml($graph, 0 - $i) . "\n"));
	}

	# Write inalign edges as comments at the end of the file
	foreach my $inalign (sort(keys(%{$graph->{'inalign'}}))) {
		$s .= "<!--<inalign>" . $inalign . "</inalign>-->\n";
	}

	# Return
	return $s;
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/psfile.pl
## ------------------------------------------------------------

=item $graph->psfile($psfile) = $psfile

Get/set PostScript file associated with graph.

=cut

sub psfile {
	my $self = shift;
	return $self->var('psfile', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/psstyle.pl
## ------------------------------------------------------------

=item $graph->psstyle($default, $context, $styles) = $ps

Return PostScript string $ps associated with style list $styles, given
style context $context and object $default defining default style
values. 

=cut

sub psstyle {
	my $self = shift;
	my $default = shift;
	my $context = shift;
	my $arg = shift;

	# Create list of styles
	my $styles = (ref($arg) eq 'ARRAY') ? $arg : [];

	# Concatenate PostScript commands associated with styles
	my $ps = "";
	foreach my $s (@$styles) {
		my $style = $self->style($default, $s);
		if ($style) {
			$ps .= $style->{$context};
		}
	}
	$ps =~ s/\s*$//;

	# Ensure PostScript string has been stored as PostScript style
	if ($ps && ! $self->{'psstyles'}{$ps}) {
		$self->{'psstyleno'} += 1;
		$self->{'psstyles'}{$ps} = $self->{'psstyleno'};
	}

	# Return PostScript style number
	return $ps ? " " . $self->{'psstyles'}{$ps} : "";
}
	

## ------------------------------------------------------------
##  auto-inserted from: Graph/pstep.pl
## ------------------------------------------------------------

=item $graph->pstep($step) = $step

Get/set step associated with graph.

=cut

sub pstep {
	my $self = shift;
	return $self->var('pstep', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/reformat.pl
## ------------------------------------------------------------

=item $graph->reformat($interpreter, $var, $value, $graph, $node) = $filtered

Return filtered value $filtered for variable $var with value $value,
using $interpreter to provide default filters. 

=cut

sub reformat {
	my $self = shift;
	my $interpreter = shift;
	my $var = shift;
	my $str = shift;
	my $graph = shift;
	my $node = shift;
	$str = "" if (! defined($str));

	# Reformat string according to specification in $self->{'format'}
	my $code = ($self->layout($interpreter, 'var') || {})->{$var};
	if ($code) {
		return &$code($str, $graph, $node, $var);
	}

	# Return formatted string
	return $str;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/relations.pl
## ------------------------------------------------------------

=item $graph->relations() 

Extract list with all relations in graph. ???

=cut

# $graph->relations({'comp' => ['subj', ...], 'adj' => ['mod', ...]}) 

# $template = 

sub relations {
	my $self = shift;
	my $template = shift;

}

sub rel_comps {
	my $self = shift;
	my $edges = shift;
	my $node = shift;

	

}

sub rel_agovs {
	my $self = shift;
	my $edges = shift;
	my $node = shift;
}



## ------------------------------------------------------------
##  auto-inserted from: Graph/sdominates.pl
## ------------------------------------------------------------

=item $graph->sdominates($lsite, $node) = $boolean

Return true if $lsite dominates $node in the surface tree, and false
otherwise.

=cut

sub sdominates {
	my $self = shift;
	my $lsite = shift;
	my $node = shift;
	my $yields = $self->var('yields');

	# Find yield segment containing $lsite, and check whether it
	# contains $node
	my ($start, $stop);
	foreach my $s (@{$yields->{$lsite}}) {
		# Fail if we skipped the yield segment containing $lsite
		return 0 if ($s->[0] > $lsite);

		# Check whether yield segment contains $node
		if ($s->[1] >= $lsite) {
			# Now yield segment contains $!node
			return ($s->[0] <= $node && $s->[1] >= $node) ? 1 : 0;
		}
	}

	# Failed to find yield segment containing both $lsite and $node
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/size.pl
## ------------------------------------------------------------

=item $graph->size() = $size

Return the number of nodes in the graph.

=cut

sub size {
	my $self = shift;
	return scalar(@{$self->nodes()});
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/source.pl
## ------------------------------------------------------------

sub source {
	my $self = shift;
	my $n = shift;
	my $node = $self->node($n);
	
	return (defined $node ? $node->var('_source') : undef) 
		|| ($self->file() . ":$n");
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/statistics.pl
## ------------------------------------------------------------

# Annotate each node with:
#	* distance to root of sentence
# 	* number of in-edges
#	* number of out-edges
#	* number of edges
#	* yield

sub statistics {
	my $self = shift;

	# Define yields and depths hashes
	my $yields = {};
	my $depths = {};

	# Define vars
	$self->vars()->{'_yield'} = undef;
	$self->vars()->{'_yieldN'} = undef;
	$self->vars()->{'_height'} = undef;
	$self->vars()->{'_depth'} = undef;
	$self->vars()->{'_maxdepth'} = undef;
	$self->vars()->{'_maxinoutN'} = undef;
	$self->vars()->{'_inN'} = undef;
	$self->vars()->{'_outN'} = undef;
	$self->vars()->{'_inoutN'} = undef;


	# Process all non-comment nodes in the graph
	$self->yields($yields);
	for (my $n = 0; $n < $self->size(); ++$n) {
		my $node = $self->node($n);
		if ($node && ! $node->comment()) {
			# Find yield of node
			$node->var('_yield', join(";",
				map {join("-", @$_)} @{$yields->{$n}}));

			# Find depth of node
			$self->depths($depths, $n);
			$node->var('_depth', $depths->{$n});

			# Find number of edges in node
			$node->var('_inN', scalar(@{$node->in()}));
			$node->var('_outN', scalar(@{$node->out()}));
			$node->var('_inoutN', 
				$node->var('_inN') + $node->var('_outN')); 

		}
	}

	for (my $n = 0; $n < $self->size(); ++$n) {
		my $node = $self->node($n);
		if ($node && ! $node->comment()) {
			# Find maximal depth and edges
			my $maxdepth = $node->var('_depth');
			my $maxedges = $node->var('_inoutN'); 
			my $nodes = 0;
			foreach my $span (@{$yields->{$n}}) {
				for (my $i = $span->[0]; $i <= $span->[1]; ++$i) {
					++$nodes;
					$maxdepth = max($maxdepth,
						$self->node($i)->var('_depth') || 0);
					$maxedges = max($maxedges,
						$self->node($i)->var('_inoutN') || 0);
				}
			}
			$node->var('_maxinoutN', $maxedges);
			$node->var('_maxdepth', $maxdepth);
			$node->var('_yieldN', $nodes);
		}
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/streams.pl
## ------------------------------------------------------------

=item $graph->streams($time1, $time2) = $streams

Return a list of stream identifiers for all streams that are active
between times $time1 and $time2 (which default to the beginning and
end of the graph, if unspecified).

=cut

sub streams {
	my $self = shift;
	my $time1 = shift || 0;
	my $time2 = shift || $self->size();
	my $streams = {};

	# Examine all nodes for streams
	for (my $i = $time1; $i < $time2; ++$i) {
		my $node = $self->node($i);
		my $stream = $node ? $node->stream() : undef;
		$streams->{$stream} = 1 if ($stream);
	}

	# Return streams
	return [sort(keys(%$streams))];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/style.pl
## ------------------------------------------------------------

=item $graph->style($default, $name) = $style

Return style $style with style name $name, using $default to find the
default values of styles. 

=cut

sub style {
	my $self = shift;
	my $default = shift;
	my $s = shift;
	my $style = $self->{'styles'} ? $self->{'styles'}{$s} : undef;
	return $style || $default->{'styles'}{$s};
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/subgraph.pl
## ------------------------------------------------------------

sub subgraph {
	my $self = shift;
	my $edge = shift;

	# Initialize subgraph
	my $subnodes = {};
	my $subedges = {};

	# Add in- and out-nodes to subgraph
	my $in = $edge->in();
	my $out = $edge->out();
	$subnodes->{$in} = 1;
	$subnodes->{$out} = 1;

	# Add all parents and grandparents of the in- and out-node
	my $maxupdist = 3;
	for (my $dist = 1; $dist < $maxupdist; ++$dist) {
		foreach my $node (keys(%$subnodes)) {
			if ($subnodes->{$node} == $dist) {
				map {
					my $nout = $_->out(); 
					$subnodes->{$nout} = $dist + 1
						if (! $subnodes->{$nout});
				} @{$self->node($node)->in()};
			}
		}
	}

	# Add all nodes at distance 4 or less
	my $maxdist = 4;
	for (my $dist = 1; $dist < $maxdist; ++$dist) {
		foreach my $node (keys(%$subnodes)) {
			if ($subnodes->{$node} == $dist) {
				map {
					my $nin = $_->in(); 
					$subnodes->{$nin} = $dist + 1
						if (! $subnodes->{$nin});
				} @{$self->node($node)->out()};
			}
		}
	}
	#print DTAG::Interpreter::dumper($subnodes), "\n";

	# Find all dependents of subnodes
	my $deps_edges = [];
	map { push @$deps_edges, @{$self->node($_)->out()} } 
		keys(%$subnodes);
	my $depnodes = [sort(map {$_->in()} @$deps_edges)];

	# Find first and last node in set
    my $subnodes_list = [sort(keys(%$subnodes))];
	my $min = $subnodes_list->[0];
	my $max = $subnodes_list->[$#$subnodes_list];

	# Add nodes to subgraph
	my $subgraph = DTAG::Graph->new($self->interpreter());
	my $positions = {};
	my $dots = 0;
	$dots = 1 if ($depnodes->[0] < $min);
	for (my $n = $min; $n <= $max; ++$n) {
		if ($subnodes->{$n}) {
			# Add dots to subgraph if necessary
			if ($dots) {
				my $dotsnode = Node->new();
				$dotsnode->input('...');
				$subgraph->node_add(undef, $dotsnode);
				$dots = 0;
			} 

			# Add subnode to subgraph
			$positions->{$n} = $subgraph->size();
			$subgraph->node_add(undef, $self->node($n)->copy());
		} elsif (! $self->node($n)->comment()) {
			$dots = 1;
		}
	}
	
	# Add dots node if dependents to right of subgraph
	if ($depnodes->[$#$depnodes] > $max) {
		my $dotsnode = Node->new();
		$dotsnode->input('...');
		$subgraph->node_add(undef, $dotsnode);
	}

	# Add edges to subgraph
	#print "Positions: ", DTAG::Interpreter::dumper($positions), "\n";
	foreach my $node (keys(%$subnodes)) {
		foreach my $e (@{$self->node($node)->in()}) {
			if (exists $positions->{$e->in()}
					&& exists $positions->{$e->out()}) {
				my $newe = $e->clone();
				$newe->in($positions->{$e->in()});
				$newe->out($positions->{$e->out()});
				$subgraph->edge_add($newe);
			}
		}
	}

	# Mark matches
	if (exists $positions->{$edge->in()} && 
			exists $positions->{$edge->out()}) {
		$subgraph->node($positions->{$edge->in()})->var('styles', 'match');
		$subgraph->node($positions->{$edge->out()})->var('styles', 'match');
		$subgraph->node($positions->{$edge->in()})->var('estyles', 
			'ematch:' . $edge->type());
	}

	# Set vars
	my $vars = $subgraph->vars($self->vars());
	$vars->{'estyles'} = undef;
	$vars->{'styles'} = undef;
	return $subgraph;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/text.pl
## ------------------------------------------------------------

=item $graph->text($separator, $maxlen) = $text

Return the first $maxlen characters of text in the graph, inserting
$separator between the text of individual nodes. $maxlen defaults to
the length of the entire graph, and $separator defaults to "".

=cut

sub text {
	my $self = shift;
	my $sep = shift || "";
	my $maxlen = shift;

	# Compute the first $maxlen chars of text of graph with separator $sep
	my $text = "";
	my $size = $self->size();
	my $first = 1;
	for (my $i = 0; $i < $size; ++$i) {
		# Add text
		my $node = $self->node($i);
		if (! $node->comment()) {
			$text .= $sep if (! $first);
			$text .= $node->input();
			$first = 0;
		}

		# Exit if $text size exceeds $max
		last() if ($maxlen && length($text) > $maxlen);
	}

	# Return text
	return $text;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/time0.pl
## ------------------------------------------------------------

=item $graph->time0($node) = $time0

Return starting time of node $node.

=cut

sub time0 {
	my $self = shift;
	my $node = shift;

	# Find node object
	my $nodeobj = $self->node($node);
	return undef if (! $nodeobj);

	# Find node object's time0
	my $time0 = $nodeobj ? $nodeobj->time0() : undef;
	return defined($time0) ? $time0 : $node;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/time1.pl
## ------------------------------------------------------------

=item $graph->time1($node) = $time1

Return ending time of node $node.

=cut

sub time1 {
	my $self = shift;
	my $node = shift;

	# Find node object
	my $nodeobj = $self->node($node);
	return undef if (! $nodeobj);

	# Find node object's time1
	my $time1 = $nodeobj ? $nodeobj->time1() : undef;
	return defined($time1) ? $time1 : $node + 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/update.pl
## ------------------------------------------------------------

sub update {
	# Called whenever graph must be updated and printed
	my $self = shift;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/var.pl
## ------------------------------------------------------------

=item $graph->var($var, $value) = $value

Get/set value $value for variable $var.

=cut

sub var {
	my $self = shift;
	my $var = shift;

	# Write new value
	$self->{$var} = shift if (@_);

	# Return value
	return $self->{$var};
}
	

## ------------------------------------------------------------
##  auto-inserted from: Graph/vars.pl
## ------------------------------------------------------------

=item $graph->vars($vars) = $vars

Get/set list $vars of user-defined variable names in graph.

=cut

sub vars {
	my $self = shift;
	return $self->var('vars', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/wikidoc.pl
## ------------------------------------------------------------

sub wikidoc {
	my $self = shift;
	my $tagvar = shift || 'msd';
	my $wikidir = shift || "treebank.dk/cdt-map";
	my $exdir = shift || $wikidir;
	my $termexcount = shift || 10;
	my $excount = shift || $termexcount;
	my $mincount = shift || 5;
	my $url = shift || "";

	# Set parameters for wiki files
	my $mapdep = "MapDep";
	my $exfile = "$exdir/examples.lst";
	my $exprefix = "ex";

	# Initialize class index
	my $instancelist = [];
	my $counts = {};

	# Index edges in graph
	$self->do_edges(sub 
		{	# Read parameters
			my $e = shift; 
			my $G = shift;
			my $var = shift;

			# Find edge type, and length 1 and 2 tags
			my $type = $e->type();
			my $inode = $G->node($e->in());
			my $onode = $G->node($e->out());
			my $i1 = substr($inode->var($var) || "", 0, 1);
			my $i2 = substr($inode->var($var) || "", 0, 2);
			my $o1 = substr($onode->var($var) || "", 0, 1);
			my $o2 = substr($onode->var($var) || "", 0, 2);
			my $iw = $inode->input();
			my $ow = $onode->input();
			$iw = "" if ($i2 ne "U=");
			$ow = "" if ($o2 ne "U=");

			# Ignore edge if type or word classes are empty, if edge
			# type starts with "<" or "[", or if edge type is on
			# the excluded list
			my $t = substr($type, 0, 1);
			return if (! ($type && $i1 && $i2 && $o1 && $o2));
			return if (! $self->is_dependent($e));

			# Find kwic-entry, cframe and subgraph
			my $lang = $self->lang($e->in());

			# Create instance
			my $instance = [$i2, $iw, $type, $o2, $ow, $lang, $e];
			push @$instancelist, $instance;

			# Create list of super types
			my $class = $self->wikidoc_class($instance);
			my @super = @{$self->wikidoc_super_all($class)};

			# Count all classes and superclasses
			foreach my $c ($class, @super) {
				++$counts->{$c};
			}
		}, $self, $tagvar);

	# Find graph structure for all classes with at least $mincount instances
	my $superclasses = {};
	my $subclasses = {};
	my $instances = {};
	foreach my $class (sort(keys(%$counts))) {
		# Skip class if it has less than $mincount instances
		next() if ($counts->{$class} < $mincount);
		$instances->{$class} = [];

		# Index all direct superclasses
		$superclasses->{$class} = [] if (! exists $superclasses->{$class});
		foreach my $super (@{$self->wikidoc_super($class)}) {
			$subclasses->{$super} = [] if (! exists $subclasses->{$super});
			push @{$superclasses->{$class}}, $super;
			push @{$subclasses->{$super}}, $class;
		}
	}

	# Find instances for all classes with at least $mincount instances
	foreach my $instance (@$instancelist) {
		my $class = $self->wikidoc_class($instance);
		foreach my $super (@{$self->wikidoc_super_all($class)}) {
			if ($instances->{$super}) {
				push @{$instances->{$super}}, $instance;
			}
		}
	}

	# Find all terminal classes
	my $terminal = {};
	foreach my $class (keys(%$instances)) {
		$terminal->{$class} = 1 if (!$subclasses->{$class});
	}

	# Simplify the graph by merging a class with its subclasses
	# if they have the same number of instances; use subclass name as
	# new name
	sub merge {
		my ($class, $subclass, $superclasses, $subclasses, $instances, $terminal) = @_;

		# Replace all instances of $class with $subclass in super
		# classes of $class
		foreach my $super (@{$superclasses->{$class}}) {
			my $newsub = {};
			map {$newsub->{$_} = 1} @{$subclasses->{$super}};
			$newsub->{$subclass} = 1;
			delete $newsub->{$class};
			$subclasses->{$super} = [sort(keys(%$newsub))];
		}

		# Add superclasses of $class as super classes of $subclass,
		# and remove $class as super class
		my $newsuper = {};
		map {$newsuper->{$_} = 1} (@{$superclasses->{$class}}, 
			@{$superclasses->{$subclass}});
		delete $newsuper->{$class};
		delete $newsuper->{$subclass};
		$superclasses->{$subclass} = [sort(keys(%$newsuper))];
		delete $superclasses->{$class};

		# Add subclasses of $class as sub classes of $subclass,
		# and remove $subclass as subclass
		my $newsub = {};
		map {$newsub->{$_} = 1} (@{$subclasses->{$subclass}},
			@{$subclasses->{$class}});
		delete $newsub->{$subclass};
		delete $newsub->{$class};
		$subclasses->{$subclass} = [sort(keys(%$newsub))];
		delete $subclasses->{$class};

		# Delete $class from all tables
		delete $instances->{$class};
		delete $terminal->{$class};
	}
	my $moremerge = 0;
	my $mergecount = 0;
	while ($moremerge) {
		print "merge cycle #", ++$mergecount, "\n";
		$moremerge = 0;
		foreach my $super (keys(%$subclasses)) {
			foreach my $class (@{$subclasses->{$super}}) {
				if (exists $instances->{$class} 
						&& exists $instances->{$super} 
						&& scalar(@{$instances->{$class}}) 
							== scalar(@{$instances->{$super}})) {
					print "merge: $super $class "
						. ($terminal->{$class} && $terminal->{$super} 
							? " terminal" : "") . "\n"
						if ($super =~ /XP/ || $class =~ /XP/);
					merge($super, $class, $superclasses, $subclasses, 
						$instances, $terminal);
					$moremerge = 1;
				}
			}
		}
	}
	

	# Map procedure: identify dependent, then governor, then edge type
	# At each DepGovType node, we have the following choices:
	#     - refine Dep (show possible subdeps with frequencies)
	#     - refine Gov (show possible subgovs with frequencies)
	#     - refine Type (show possible subtypes with frequencies)
	#	  - refine language
	#     - show N random examples

	# Read examples from file
	my $examples = {}; 
	my $examples_hash = {};
	my $excounter = 0;
	if (-f $exfile) {
		# Read examples from file
		open(IFH, "<$exfile");
		my $line = <IFH>;
		chomp($line);
		$excounter = $line;
		while ($line = <IFH>) {
			# Read example line
			chomp($line);
			my $example = [split(/\t/, $line)];
			my ($class, $file, $source, $text) = @$example;
			print "old example: ", join("\t", @$example), "\n";

			# Record example
			$examples->{$class} = []
				if (! exists $examples->{$class});
			push @{$examples->{$class}}, $example;
			$examples_hash->{$class . ":" . $text} = $example;
		}
	}

	sub shuffle {
		srand;
    	my @new = ();
    	for(@_){
       		my $r = rand @new+1;
       		push(@new, $new[$r]);
        	$new[$r] = $_;
		}
		return @new;
    }

	# Generate examples randomly for terminal classes
	my $done = {};
	foreach my $tclass (keys(%$terminal)) {
		# Ensure that examples exist, and generate random list of examples
		$examples->{$tclass} = [] if (! exists $examples->{$tclass});
		my @shuffled = shuffle(@{$instances->{$tclass}});
		$done->{$tclass} = 1;

		# Generate desired number of examples
		my $n = $termexcount - scalar(@{$examples->{$tclass}});
		while ($n > 0 && @shuffled) {
			# Generate example from instance
			my $instance = shift(@shuffled);
			my $edge = $instance->[$#$instance];
			my $source = $self->source($edge->in());
			my $subgraph = $self->subgraph($edge);
			my $text = $subgraph->text(" ");

			# Use example if it hasn't been used before
			if (! $examples_hash->{$tclass . ":" . $text}) {
				# Generate file name and record example
				my $file = $exprefix . sprintf("%04d", ++$excounter) 
					. "-" .  classname($tclass);
				my $example = [$tclass, $file, $source, $text];
				push @{$examples->{$tclass}}, $example;
				$examples_hash->{$tclass . ":" . $text} = $example;

				# Save example in file
				print "new example: ", join("\t", @$example), "\n";
				open(EX, ">$exdir/$file.tag");
				print EX "<!-- " . join("\t", @$example) . "-->\n";
				print EX $subgraph->print_tag();
				close(EX);

				# Decrement example counter
				--$n;
			}
		}
	}

	# Generate examples randomly for non-terminal classes: eg, if class
	# has subclasses s1,s2,s3 (ordered by their instance count) and we 
	# need 5 examples, we randomly pick example from s1,s2,s3,s1,s2
	my $incomplete = 1;
	while ($incomplete) {
		$incomplete = 0;
		foreach my $class (sort(keys(%$instances))) {
			# Skip class if it is done 
			next() if ($done->{$class});
			print "TERMINAL $class!!!\n" if ($terminal->{$class});
			
			# Skip class if one of its subclasses is not done
			my @subs = @{$subclasses->{$class}};
			if (grep {! $done->{$_}} @subs) {
				$incomplete = 1;
				next();
			}

			# Order examples from subclasses randomly
			my $hash = {};
			my $nsubs = scalar(@subs);
			for (my $i = 0; $i <= $#subs; ++$i) {
				# Shuffle examples by recording example $j for subclass 
				# $i under integer $j * nsubs + $i
				my $sub = $subs[$i];
				my @exlist = @{$examples->{$sub}};
				for (my $j = 0; $j <= $#exlist; ++$j) {
					$hash->{$j * $nsubs + $i} = $exlist[$j];
				}
			}
			my @shuffled = (
				@{$examples->{$class} || []}, 
				map {$hash->{$_}} sort(keys(%$hash)));

			# Pick the desired number of examples
			my $n = max(scalar(@{$examples->{$class} || []}), 
				min(scalar(@shuffled), $excount));
			$hash = {};
			my $exlist = $examples->{$class} = [];
			for (my $i = 0; $i <= $#shuffled && $n > 0; ++$i) {
				my $example = [@{$shuffled[$i]}];
				$example->[0] = $class;
				my $file = $example->[1];
				if (! $hash->{$file}) {
					push @$exlist, $example;
					$hash->{$file} = $example;
					--$n;
				}
			}
			$done->{$class} = 1;
		}
	}

	# Write example file $exfile
	if (open(EX, ">$exfile")) {
		print EX $excounter, "\n";
		foreach my $class (sort(keys(%$examples))) {
			# Only print terminal classes
			next() if (! $terminal->{$class});
			foreach my $example (@{$examples->{$class}}) {
				if ($example) {
					print EX join("\t", @$example) . "\n";
				} else {
					print "Undefined example for $class\n";
				}
			}
		}
		close(EX);
	} else {
		error("Cannot open $exfile for writing!");
	}

	# Create map files
	sub dimension {
		my $cls = shift;
		my $dm = shift;
		my @lst = split('_', $cls);
		return $lst[$dm] || "";
	}

	sub classname {
		my $cls = shift;
		my @lst = split('_', $cls);
		return join("", map {$_ || '_'} @lst);
	}

	sub wiki_url {
		my ($link, $text) = @_;
		return "<a href=\"$link\">$text</a>";
	}

	sub supf {
		my $url = shift;
		my $mapdep = shift;
		my $class = shift;
		my $list = shift;
		my $dim = shift;
		return join(" ", sort(map { 
			wiki_url($url . $mapdep . classname($_) . ".html", dimension($_, $dim) || "ANY") }
				@$list));	
	}

	sub subf {
		my $url = shift;
		my $mapdep = shift;
		my $instances = shift;
		my $class = shift;
		my $list = shift;
		my $dim = shift;
		return join(" ", map {
			wiki_url($url . $mapdep . classname($_) . ".html", dimension($_, $dim)) 
				. sprintf("<sub>%d%%</sub>", scalar(@{$instances->{$_}}) /
					scalar(@{$instances->{$class}}) * 100)
			} sort {scalar(@{$instances->{$b}}) <=>
				scalar(@{$instances->{$a}})} @$list);
	}

	foreach my $class (keys(%$instances)) {
		# Retrieve
		# Categorize superclasses
		my $superlist = [[], [], [], [], []];
		foreach my $super (@{$superclasses->{$class}}) {
			map {push @{$superlist->[$_]}, $super} 
				wikidoc_subclass_dim($class, $super);
		}
		my $supdeps = supf($url, $mapdep, $class, $superlist->[0], 0);
		my $suprels = supf($url, $mapdep, $class, $superlist->[1], 1);
		my $supgovs = supf($url, $mapdep, $class, $superlist->[2], 2);
		my $suplangs = supf($url, $mapdep, $class, $superlist->[3], 3);

		# Categorize subclasses
		my $sublist = [[], [], [], [], []];
		foreach my $sub (@{$subclasses->{$class}}) {
			map {push @{$sublist->[$_]}, $sub} 
				wikidoc_subclass_dim($sub, $class);
		}

		my $subdeps = subf($url, $mapdep, $instances, $class, $sublist->[0], 0);
		my $subgovs = subf($url, $mapdep, $instances, $class, $sublist->[2], 2);
		my $sublangs = subf($url, $mapdep, $instances, $class, $sublist->[3], 3);
		my $subcomps = subf($url, $mapdep, $instances, $class, [grep {$self->is_complement(dimension($_, 1))} @{$sublist->[1]}], 1);
		my $subadjs = subf($url, $mapdep, $instances, $class, [grep {$self->is_adjunct(dimension($_, 1))} @{$sublist->[1]}], 1);
		my $subrels = ($subcomps ? "<p><b>complement:</b><br> " . $subcomps .  "<br>\n" : "")
			. ($subadjs ? "<p><b>adjunct:</b><br>" . $subadjs . "\n" : "");

		#print "no super: $class instances=" 
		#	.  scalar(@{$instances->{$class}}) 
		#	. ($terminal->{$class} ? " terminal" : "")
		#	. "\n"
		#	if (! @{$superclasses->{$class}});

		my ($dependent, $relation, $governor, $language) = 
			map {dimension($class, $_)} (0, 1, 2, 3);

		# Examples
		my $examplestring = "";
		foreach my $example (@{$examples->{$class}}) {
			my ($class, $file, $source, $text) = @$example;
			if ($text && $source && $file) {
				$examplestring .=
					"<p><b>text:</b> $text</p>\n\n" .
					"<img src=\"$url$file.png\">\n\n" .
					"<p><b>source:</b> $source</p>\n\n" .
					"<hr>\n";
			}
		}
		
		# Print wiki
		open(WIKI, "> $wikidir/$mapdep" . classname($class) . ".html");
		print WIKI "<html>\n"
			. "<head>\n"
			. "<META http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\">\n"
			. "<body>\n"
			. "<h2>$mapdep" . classname($class) . ": " . join(" + ", grep {$_} (
			$dependent ? "dependent $dependent" : "",
			$relation ? "relation $relation" : "",
			$governor ? "governor $governor" : "",
			$language ? "language $language" : ""))
			. " (" . scalar(@{$instances->{$class}}) . " instances)</h2>\n\n";
		print WIKI "<table rules=\"all\" frame=\"all\"><tr><th></th><th>Dependent</th><th>Governor</th><th>Relation</th><th>Language</th></tr>\n";
		print WIKI "<tr><th>Super</th><td>$supdeps</td><td>$supgovs</td><td>$suprels</td><td>$suplangs</td></tr>\n";
		print WIKI "<tr><th>Sub</th><td>$subdeps</td><td>$subgovs</td><td>$subrels</td><td>$sublangs</td></tr></table>\n";
		print WIKI "\n\n<h3>Examples</h3>\n";
		print WIKI $examplestring;
		print WIKI "</body></html>\n";
		close(WIKI);
	}
	
	$self->var('wikidoc_term', $terminal);
	$self->var('wikidoc_sup', $superclasses);
	$self->var('wikidoc_sub', $subclasses);
	$self->var('wikidoc_inst', $instances);
	$self->var('wikidoc_ex', $examples);


	print "classes=", scalar(keys(%$instances)), 
	" instances=", scalar(@$instancelist), 
	" terminal=", scalar(keys(%$terminal)), "\n";
	# classes=4140 instances=3714 terminal=2927
	# classes=928 instances=3714 terminal=188
	# classes=740 instances=3714 terminal=126
	# classes=453 instances=3714 terminal=126
	# classes=2862 instances=89907 terminal=571
	# classes=1576 instances=89907 terminal=478

}

sub wikidoc_subclass_dim {
	my ($a, $b) = @_;
	my @cls = split('_', $a);
	my @sbcls = split('_', $b);
	my @dms = ();
	for (my $i = 0; $i <= $#cls || $i <= $#sbcls; ++$i) {
		push @dms, $i 
			if (($cls[$i] || "") ne ($sbcls[$i] || ""));
	}
	return @dms;
}

sub wikidoc_class {
	my $self = shift;
	my $instance = shift;
	my ($i2, $iw, $type, $o2, $ow, $lang) = @$instance;
	$i2 =~ s/[^A-Za-z]//g;
	$o2 =~ s/[^A-Za-z]//g;
	$type =~ s/[^A-Za-z]//g;
	$iw =~ s/[^A-Za-z]//g; 
	$ow =~ s/[^A-Za-z]//g;
	$lang =~ s/[^A-Za-z]//g;

	my $class = join("_", 
		uc($i2) . uc($iw), 
		lc($type),
		uc($o2) . uc($ow),
		$lang);
	#print $class, "\n";
	return $class;
}

sub wikidoc_super {
	my $self = shift;
	my $class = shift;
	my ($i, $t, $o, $l) = split('_', $class);

	my $super = [];
	push @$super, join("_", wikidoc_superw($i), $t, $o, $l) if ($i);
	push @$super, join("_", $i, "", $o, $l) if ($t);
	push @$super, join("_", $i, $t, wikidoc_superw($o), $l) if ($o);
	push @$super, join("_", $i, $t, $o, "") if ($l);
	
	#print "super($class): " . join(" ", @$super) . "\n";
	return $super;
}

sub wikidoc_super_all {
	my $self = shift;
	my $class = shift;
	my $supers = shift || {};

	if (! $supers->{$class}) {
		$supers->{$class} = 1;
		foreach my $s (@{$self->wikidoc_super($class)}) {
			$self->wikidoc_super_all($s, $supers);
		}
	}
	return [sort(keys(%$supers))];
}

sub wikidoc_superw {
	my $wclass = shift;
	$wclass =~ /^([A-Z]*)([^A-Z]*)$/;
	my ($tag, $word) = ($1, $2);

	# Word present
	return undef if (length($tag) == 0);
	return $tag if (length($word) != 0);
	return "" if (length($tag) == 1);
	return substr($tag, 0, 1);
}



## ------------------------------------------------------------
##  auto-inserted from: Graph/words.pl
## ------------------------------------------------------------

=item $graph->words($i1, $i2, $separator) = $text

=cut

my $digits = "\x{2070}\x{00B9}\x{00B2}\x{00B3}\x{2074}\x{2075}\x{2076}\x{2077}\x{2078}\x{2079}";

sub words {
	my $self = shift;
	my $i1 = shift;
	my $i2 = shift;
	my $sep = shift || "";
	my $maxlen = shift;
	my $unicode = shift || 1;

	# Ensure $i1 and $i2 are set
	$i1 = 0 if (! defined($i1));
	$i2 = $self->size()-1 if (! defined($i2));
	$i1 = max($i1, 0);
	$i2 = min($i2, $self->size()-1);

	# Compute text
	my $text = "";
	my $size = $self->size();
	my $first = 1;
	my $lastten = -1000;
	for (my $i = $i1; $i <= $i2; ++$i) {
		# Add text
		my $node = $self->node($i);
		if (! $node->comment()) {
			$text .= $sep if (! $first);
			if ($unicode) {
				if ($i - $lastten >= 10) {
					# Print entire text
					$text .= superscript($i - $self->offset());
					$lastten = $i - ($i % 10);
				} else {
					# Print only last digit
					my $sup = superscript($i -$self->offset());
					$text .= substr($sup, length($sup) - 1);
				}
			}
			
			if (Encode::decode_utf8($node->input())) {
				$text .=  Encode::decode_utf8($node->input());
			} else {
				$text .= $node->input();
			}
			$first = 0;
		}
	}

	# Return text
	return $text;
}


sub superscript {
	my $n = "" . shift;

	my $s = "";
	for (my $i = 0; $i < length($n); ++$i) {
		my $digit = substr($n, $i, 1);
		$s .= substr($digits, 0 + $digit, 1);
	}

	return $s;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/yield_simplify.pl
## ------------------------------------------------------------

=item $graph->yield_simplify(@intervals) = @newintervals

Compute simplified set of intervals from @intervals = ([$start1,
$stop1], ...), and return in @newintervals.

=cut

sub yield_simplify {
	my $self = shift;

	# Sort intervals in yield according to start element
	my @yield = sort {$a->[0] <=> $b->[0]} @_;

	# Merge intervals into one
	my @new = ();
	my $interval = shift(@yield);
	my $start = $interval->[0];
	my $stop = $interval->[1];

	# Process intervals
	my $saved;
	foreach $interval (@yield) {
		# Skip comment nodes
		while ($self->node($stop+1)->comment()) {
			++$stop;
		}

		# Read next interval
		my $start2 = $interval->[0];
		my $stop2 = $interval->[1];

		# Determine whether intervals overlap
		if ($start2 <= $stop + 1) {
			# Intervals overlap
			$stop = $stop2 if ($stop2 > $stop);
		} else {
			# Intervals do not overlap
			push @new, [$start, $stop];
			$start = $start2;
			$stop = $stop2;
		}
	}

	# Save last interval
	push @new, [$start, $stop];

	# Return simplified yield
	return @new;
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/yields.pl
## ------------------------------------------------------------

=item $graph->yields($yields, $node) = $yields

Compute yields hash $yields containing the yield of node $node and the
yield of all other nodes in the yield of $node. 

=cut

sub yields {
	my $self = shift;
	my $yields = shift;
	my $node = shift;

	# Save yields in graph, if undefined
	$yields = $self->var('yields', {})	
		if (! $yields);
	
	# Process all nodes
	if (! defined($node)) {
		for ($node = 0; $node < $self->size(); ++$node) {
			$self->yields($yields, $node);
		}
	} else {
		# Find node object
		my $nodeobj = $self->node($node);

		# Skip node if it is a comment, a filler, or undefined, or if
		# its yield is defined already
		return $yields if ((! $nodeobj) 
			|| $nodeobj->comment() 
			|| (! $nodeobj->input()) 
			|| defined($yields->{$node}));
		$yields->{$node} = [];

		# Calculate non-filler dependents
		my @yield = ();
		push @yield, [$node, $node]
			if (length($nodeobj->input() || "") > 0);
		my $out = $nodeobj->out();
		my $etypes = $self->etypes();
		foreach my $e (@$out) {
			# Test whether edge is a complement or an adjunct
			if ($self->is_dependent($e)) {
				# Find yield of dependent
				$self->yields($yields, $e->in());
				push @yield, @{$yields->{$e->in()} || []};
			}
		}

		# Save yield
		#$yields->{$node} = [$self->yield_simplify(@yield)];
		push @{$yields->{$node}}, 
			$self->yield_simplify(@yield);
	}
		
	# Return yields
	return $yields;
}


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
##  auto-inserted from: Graph/Edge/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 Edge

=head2 NAME

Edge - edge in dependency graph

=head2 DESCRIPTION

Edge - edge in dependency graph.

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package Edge;
use strict;



## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/clone.pl
## ------------------------------------------------------------

=item $edge->clone() = $clone

Return clone $clone of edge $edge.

=cut

sub clone {
	my $self = shift;
	return Edge->new($self->in(), $self->out(), $self->type());
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/cost.pl
## ------------------------------------------------------------

=item $edge->cost($cost) = $cost

Get/set edge cost.

=cut

sub cost {
	my $self = shift;
	$self->[3] = shift if (@_);
	return $self->[3];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/eq.pl
## ------------------------------------------------------------

=item $edge->eq($edge2) = $boolean

Test whether $edge and $edge2 represent the same edge.

=cut

sub eq {
	my $self = shift;
	my $edge = shift;
	my $unlabelled = shift;

	return ($self->out() == $edge->out())
		&& ($self->in() == $edge->in())
		&& ($unlabelled || $self->type() eq $edge->type());
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/in.pl
## ------------------------------------------------------------

=item $edge->in($in) = $in

Get/set in-node $in of edge. 

=cut

sub in {
	my $self = shift;
	$self->[0] = shift if (@_);
	return $self->[0];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/match.pl
## ------------------------------------------------------------

=item $edge->match($typedef) = $boolean

Test whether $edge matches type definition $typedef, which must be a
regular expression or an atomic name. 

=cut

sub match {
	my $self = shift;
	my $typedef = shift;

	if ($typedef =~ /^\/.*\/$/) {
		# Regular expression
		my $name = $self->type();
		return 1 if (eval("\$name =~ $typedef"));
	} else {
		# Atomic name
		return 1 if ($self->type() eq $typedef);
	}

	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/new.pl
## ------------------------------------------------------------

=item Edge->new() = $edge

Create new edge $edge.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self: 0=in 1=out 2=type 3=cost 4=tags 5=style
	my $self = [ @_ ];

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/out.pl
## ------------------------------------------------------------

=item $edge->out($out) = $out

Get/set out-node for edge.

=cut

sub out {
	my $self = shift;
	$self->[1] = shift if (@_);
	return $self->[1];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/print.pl
## ------------------------------------------------------------

=item $edge->print() = $string

Return string representation of edge (used for debugging only).

=cut

sub print {
	my $self = shift;
	return "edge("
		. "in=" . $self->in()
		. " out=" . $self->out()
		. " type=" . $self->type() . ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/type.pl
## ------------------------------------------------------------

=item $edge->type($type) = $type

Get/set edge type.

=cut

sub type {
	my $self = shift;
	$self->[2] = shift if (@_);
	return $self->[2];
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/var.pl
## ------------------------------------------------------------

=item $edge->var($var, $value) = $value

Get/set value $value for variable $var in edge.

=cut

sub var {
	my $self = shift;
	my $var = shift;
	my $vars = $self->vars();

	# Supply new value
	if (@_) {
		my $value = shift;

		# Add variable, if non-existent
		if ($vars !~ /§$var=/) {
			$vars .= "$var=$value§";
		} else {
			# Replace variable value
			$vars =~ s/§$var=[^§]*§/§$var=$value§/;
		}

		# Return value
		$self->vars($vars);
		return $value;
	}

	# Dirty Perl hack needed to reset $1 to ""
	my $e = "";
	$e =~ /^(\s*)$/;

	# Find existing value
	$vars =~ /§$var=([^§]*)§/;
	return $1 || "";
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/Edge/vars.pl
## ------------------------------------------------------------

=item $edge->vars($vars) = $vars

Get/set variable string for edge, used for storing variable-value
pairs. 

=cut

sub vars {
	my $self = shift;
	$self->[4] = shift if (@_);
	return $self->[4] || "§";
}

1;
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
##  auto-inserted from: Graph/Node/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 Node

=head2 NAME

Node - Node in DTAG::Graph

=head2 DESCRIPTION

Node - node in dependency graph

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package Node;
use strict;
use Term::ANSIColor;
use Data::Dumper;
$Data::Dumper::Indent = 0;

my $color = 0;



## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/active.pl
## ------------------------------------------------------------

=item $node->active($active) = $active

Get/set list $active of active lexemes associated with node $node. 

=cut

sub active {
	my $self = shift;
	return $self->var('_active', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/comment.pl
## ------------------------------------------------------------

=item $node->comment($comment) = $comment

Get/set comment status of node: 1 = comment, 0 = not comment.

=cut

sub comment {
	my $self = shift;
	return $self->var('_comment', @_);
}
	

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/copy.pl
## ------------------------------------------------------------

=item Node->copy() = $node

Create new copy of node.

=cut

sub copy {
	# Create new node
	my $self = shift;
	my $copy = Node->new();

	# Copy old node to new node
	foreach my $key (keys(%$self)) {
		if ($key !~ /^\_/) {
			$copy->{$key} = $self->{$key};
		}
	}
	$copy->input($self->input());

	# Return copy
	return $copy
}


## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/cost.pl
## ------------------------------------------------------------

=item $node->cost($cost) = $cost

Get/set cost associated with node.

=cut

sub cost {
	my $self = shift;
	return $self->var('_cost', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/dumpstr.pl
## ------------------------------------------------------------

=item dumpstr($object) = $string

Return string representation of object.

=cut

sub dumpstr {
	my $str = Dumper(shift);
	$str =~ s/^.*=\s*(.*)\s*;\s*$/$1/g;
	if ($str =~ /^["'].*["']$/g) {
		# Normal string: convert to double-quoted string
		$str =~ s/"/&quot;/g;
		$str =~ s/^'(.*)'$/"$1"/g;
	}

	$str =~ s/^([^"'].*)$/`$1`/g;
	return $str;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/extracted.pl
## ------------------------------------------------------------

=item $node->extracted($extracted) = $extracted

Get/set list of extractions though $node.

=cut

sub extracted {
	my $self = shift;
    return $self->var('_extracted', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/in.pl
## ------------------------------------------------------------

=item $node->in($in) = $in

Get/set list $in of in-edges for node $node.

=cut

sub in {
	my $self = shift;
	return $self->var('_in', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/input.pl
## ------------------------------------------------------------

=item $node->input($input) = $input

Get/set node input.

=cut

sub input {
	my $self = shift;
    return $self->var('_input', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/layout.pl
## ------------------------------------------------------------

=item $node->layout($layout) = $layout

Get/set node layout.

=cut

sub layout {
	my $self = shift;
    return $self->var('_layout', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/lexemes.pl
## ------------------------------------------------------------

=item $node->lexemes($lexemes) = $lexemes

Get/set list $lexemes of lexemes associated with node $node.

=cut

sub lexemes {
	my $self = shift;
    return $self->var('_lexemes', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/new.pl
## ------------------------------------------------------------

=item Node->new() = $node

Create new node.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self
	my $self = {
		'_in' => [],
		'_out' => [],
		'_lexemes' => [],
		'_active' => [],
		'_cost' => 0,
		'_extracted' => [] };

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/out.pl
## ------------------------------------------------------------

=item $node->out($out) = $out

Get/set list $out of out-edges at node $node.

=cut

sub out {
	my $self = shift;
	return $self->var('_out', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/position.pl
## ------------------------------------------------------------

=item $node->position($pos) = $pos

Get/set node position.

=cut

sub position {
	my $self = shift;
	return $self->var('_position', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/print.pl
## ------------------------------------------------------------

=item $node->print() = $string

Return string representation of $node (used for debugging only).

=cut

sub print {
	my $self = shift;
	return "node("
		. "input=" . $self->input()
		. " segment=" . $self->segment()
		. " position=" . $self->position()
		. " lexemes=[" . join(",", @{$self->lexemes()}) . "]"
		. " active=[" . join(",", @{$self->active()}) . "]"
		. " selected=" . $self->selected()
		. " cost=" . $self->cost()
		. " in=[" . join(",", @{$self->in()}) . "]"
		. " out=[" . join(",", @{$self->out()}) . "]"
		. " extracted=[" . join(",", @{$self->extracted()}) . "]"
		. " layout=" . $self->layout()
		. ")";
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/relpos.pl
## ------------------------------------------------------------

=item $node->relpos($offset, $pos) = $relpos

Return relative position $relpos of node with position $pos and offset
$offset.

=cut

sub relpos {
	my $offset = shift;
	my $pos = shift;

	return $pos ? int($pos-$offset) : "";
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/segment.pl
## ------------------------------------------------------------

=item $node->segment($segment) = $segment

Get/set list of segments associated with node.

=cut

sub segment {
	my $self = shift;
	return $self->var('_segment', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/selected.pl
## ------------------------------------------------------------

=item $node->selected($selected) = $selected

Get/set selected lexeme at node. 

=cut

sub selected {
	my $self = shift;
	return $self->var('_selected', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/stream.pl
## ------------------------------------------------------------

=item $node->stream($stream) = $stream

Get/set stream associated with node (default stream = 0).

=cut

sub stream {
	my $self = shift;
	return $self->var('stream', @_) || 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/time0.pl
## ------------------------------------------------------------

=item $node->time0($time0) = $time0

Get/set starting time at node.

=cut


sub time0 {
	my $self = shift;
	return $self->var('time0', @_) || undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/time1.pl
## ------------------------------------------------------------

=item $node->time1($time1) = $time1

Get/set ending time at node $node.

=cut


sub time1 {
	my $self = shift;
	return $self->var('time1', @_) || undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/use_color.pl
## ------------------------------------------------------------

=item $node->use_color($color) = $color

Get/set color used at $node. ???

=cut

sub use_color {
	my $self = shift;
	$color = shift if (@_);
	return $color;
}

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/var.pl
## ------------------------------------------------------------

=item $node->var($var, $value) = $value

Get/set value $value associated with variable $var at $node.

=cut

sub var {
	my $self = shift;
	my $var = shift;

	# Write new value
	$self->{$var} = shift if (@_);

	# Return value
	return $self->{$var};
}
	

## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/varstr.pl
## ------------------------------------------------------------

=item $node->varstr($var, $perlexpr) = $perlexpr

Get/set value for variable $var, using a string $perlexpr evaluated
as a Perl expression.

=cut

sub varstr {
	my $self = shift;
	my $var = shift;

	# Write new value
	$self->{$var} = eval(shift) if (@_);

	# Return value
	return dumpstr($self->{$var});
}



## ------------------------------------------------------------
##  auto-inserted from: Graph/Node/xml.pl
## ------------------------------------------------------------

=item $node->xml($graph, $displace) = $xml

Return xml-representation $xml of node $node within graph $graph,
where $displace is the position of the node in the file. 

=cut

sub xml {
	my $self = shift;
	my $graph = shift;
	my $displace = shift || 0;

	sub emph {
		my $text = shift;
		return colored($text, 'bold red') if ($color);
		return $text;
	}

	sub emph_input {
		my $text = shift;

		$text =~ s/</&lt;/g;
		$text =~ s/>/&gt;/g;

		return colored($text, 'bold blue') if ($color);
		return $text;
	}	

	# Node represents a comment, to be printed verbatim
	return $self->input() if ($self->comment());

	# XML format with variable-value pairs
	my $string = "<W";

	# Variable-value pairs
	foreach my $var (sort(keys %$self)) {
		if (exists $graph->vars()->{$var}) {
			my $value = $self->var($var);
			$value = ref($value) ? $self->varstr($var) : "\"$value\"";
			$value = "\"\"" if ("$value" eq "");
			$string .= " $var=" . emph($value) . "";
		}
	}

	# In-edges
	my @edges = ();
	foreach my $e (@{$self->in()}) {
		push @edges, ($displace + $e->out()) . ":" . $e->type()
			unless ($e->var('ignore'));
	}
	$string .= " in=\"" . emph(join("|", @edges)) . "\"";

	# Out-edges
	@edges = ();
	foreach my $e (@{$self->out()}) {
		push @edges, ($displace + $e->in()) . ":" . $e->type()
			unless ($e->var('ignore'));
	}
	$string .= " out=\"" . emph(join("|", @edges)) . "\"";

	# Return value
	$string .= ">" . emph_input($self->input()) . "</W>";
	return $string;
}


1;

1;
