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
##  auto-inserted from: Alignment/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 DTAG::Alignment

=head2 NAME

DTAG::Alignment - DTAG alignment graphs

=head2 DESCRIPTION

DTAG::Alignment - creating, manipulating and drawing alignments

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::Alignment;
require DTAG::Interpreter;
use strict;

# Graph identifier
my $alignment_id = 0;

# PostScript 
my $pstrailer = {};
my $psheader = {};

sub readfile {
    my $file = shift;
    my $string = "";

    # Read file
    open(IFH, $file) 
		|| return DTAG::Interpreter::error("cannot read file $file in Alignment->readfile\n" .
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
$psheader->{'align'}  = readfile("$src/align.header");
$pstrailer->{'align'} = readfile("$src/align.trailer");



## ------------------------------------------------------------
##  auto-inserted from: Alignment/AUTOLOAD.pl
## ------------------------------------------------------------

sub AUTOLOAD {
	use vars qw($AUTOLOAD);
	DTAG::Interpreter::error("non-existent method $AUTOLOAD")
		if ($AUTOLOAD !~ /::DESTROY$/);
	return undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/abs2rel.pl
## ------------------------------------------------------------

sub abs2rel {
	my $self = shift;
	my $key = shift;
	my $abs = shift;

	return $abs - ($self->{'offsets'}{$key} || 0);
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/add_edge.pl
## ------------------------------------------------------------

sub add_edge {
	my $self = shift;
	my $edge = shift;

	# Add edge to list of edges
	push @{$self->{'edges'}}, $edge;

	# Index edges by nodes
	my $outkey = $edge->outkey();
	my $inkey = $edge->inkey();
	foreach my $key (
			(map {$outkey . $_} @{$edge->outArray()}),
			(map {$inkey . $_} @{$edge->inArray()})) {
		$self->add_key($key, $edge);
	}

	# Find all crossing edges
	my $edge_crossings = $self->new_crossings($edge);
	my $crossings = $self->var('crossings');
	$crossings->{$edge} = $edge_crossings;
	foreach my $e (@$edge_crossings) {
		push @{$crossings->{$e}}, $edge;
	}

	# Find all creator=-101 edges coincident with this edge, and delete them
	my $deledges = {};
	foreach my $n (@{$edge->inArray()}) {
		map {$deledges->{$_} = $_} @{$self->node_edges($inkey, $n)};
	}
	foreach my $n (@{$edge->outArray()}) {
		map {$deledges->{$_} = $_} @{$self->node_edges($outkey, $n)};
	}
	foreach my $e (sort {$b <=> $a} values(%$deledges)) {
		# print "deledge=" . (defined($e) ? $e : "undef") . 
			" " . (defined($self->edge($e)) 
				?  $self->edge($e)->string() : "undef") . "\n";
		$self->del_edge($e)
			if ($self->edge($e) ne $edge && 
				$self->edge($e)->creator() <= -100);
	}

	# Return
	return $edge;
} 

## ------------------------------------------------------------
##  auto-inserted from: Alignment/add_graph.pl
## ------------------------------------------------------------

sub add_graph {
	my $self = shift;
	my $key = shift;
	my $graph = shift;

	$self->{'graphs'}{$key} = $graph;
	$self->{'offsets'}{$key} = 0;
} 

## ------------------------------------------------------------
##  auto-inserted from: Alignment/add_key.pl
## ------------------------------------------------------------

sub add_key {
	my $self = shift;
	my $key = shift;
	my $edge = shift;

	# Create node, if necessary
	my $nodes = $self->var('nodes');
	if (! exists $nodes->{$key}) {
		$nodes->{$key} = [];
	}

	# Add edge to node list
	push @{$nodes->{$key}}, $edge;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/alexicon.pl
## ------------------------------------------------------------

sub alexicon {
	my $self = shift;
	return $self->var('alexicon', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/auto_offset.pl
## ------------------------------------------------------------

sub auto_offset {
	my $self = shift;

	# Delete automatically created alignment edges
	$self->delete_creator(-100, -100);
	
	# Find offsets for all graphs
	foreach my $key (keys(%{$self->graphs()})) {
		# Find first node in graph without edges
		my $offset = $self->node_incomplete($key, $self->offset($key));

		# Set offset
		$self->offset($key, $offset);
		$self->imin($key, $offset - $self->var('window'));
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/bindgraph.pl
## ------------------------------------------------------------

sub bindgraph {
	my $self = shift;
	my $bindings = shift;
	my $key = shift || "G";
	my $graphs = $self->{'graphs'};
	foreach my $akey (keys(%$graphs)) {
		my $graph = $graphs->{$akey};
		$graph->bindgraph($bindings, "$key$akey")
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/clear.pl
## ------------------------------------------------------------

sub clear {
	my $self = shift;

	$self->var('graphs', {});
	$self->var('imin', {});
	$self->var('imax', {});
	$self->var('edges', []);
	$self->var('offsets', {});
	$self->var('nodes', {});
	$self->var('crossings', {});
	$self->var('window', 10);

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: Alignment/compile_edges.pl
## ------------------------------------------------------------

# Specify the edges in the alignment directly (time-consuming)

sub set_edges {
	my $self = shift;
	my $edges = shift;

	# Erase all edges in the graph
	$self->erase_all();

	# Add all edges to the graph
	foreach my $edge (@$edges) {
		$self->add_edge($edge);
	}

	# Return
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/component.pl
## ------------------------------------------------------------

sub component {
	my $self = shift;

	# Parameters
	my $outkey = "a";
	my $inkey = "b";

	# Create initial queue
	my $queue = {};
	foreach my $edge (@_) {
		$queue->{$edge} = $edge;
	}

	# Find all crossing edges
	my $E = $self->edges();
	my $edges = {};
	my ($omin, $omax, $imin, $imax) = (1e30, -1e30, 1e30, -1e30);
	while (my ($edge) = values(%$queue)) {
		# Read next edge in queue, and add it to edges hash
		delete $queue->{$edge};
		$edges->{$edge} = $edge;
		$omin = min($omin, @{$edge->outArray()}) 
			if ($edge->outkey() eq $outkey);
		$omax = max($omax, @{$edge->outArray()})
			if ($edge->outkey() eq $outkey);
		$imin = min($imin, @{$edge->inArray()})
			if ($edge->inkey() eq $inkey);
		$imax = max($imax, @{$edge->inArray()})
			if ($edge->inkey() eq $inkey);

		# Push all crossing edges onto queue
		map {$queue->{$_} = $_ if (! $edges->{$_})} 
			@{$self->crossings($edge)};

		# Find all intervening edges, if queue is empty
		if (! values(%$queue)) {
			# Intervening out-edges
			if ($omax < 1e30) {
				for (my $o = $omin; $o <= $omax; ++$o) {
					map {
						$queue->{$_} = $_ if (! exists $edges->{$_});
					} @{$self->node($outkey, $o)};
				}
			}

			# Intervening in-edges
			if ($imax < 1e30) {
				for (my $i = $imin; $i <= $imax; ++$i) {
					map {
						$queue->{$_} = $_ if (! exists $edges->{$_});
					} @{$self->node($inkey, $i)};
				}
			}
		}
	}

	# Sort edges
	my $sorted = [
		sort {
				# Deletion edges come first
				(($a->outkey() ne $a->inkey())
				<=>
				($b->outkey() ne $b->inkey())) 
				
				|| 

				# Preceding nodes in component
				((min(@{$a->outArray()}) 
					+ min(@{$a->inArray()})
					- $omin - $imin) 
				<=> 				
				(min(@{$b->outArray()}) 
					+ min(@{$b->inArray()})
					- $omin - $imin))
		} values(%$edges)
	];


	# Return all edges
	return $sorted;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/crossings.pl
## ------------------------------------------------------------

sub crossings {
	my $self = shift;
	my $edge = shift;
	my $crossings = $self->var('crossings');
	return ($crossings && exists $crossings->{$edge}) ? $crossings->{$edge} : [];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/del_edge.pl
## ------------------------------------------------------------

sub del_edge {
	my $self = shift;
	my $e = shift;

	# Delete edge from edge array
	my $edges = $self->edges();
	my $edge = $edges->[$e];
	splice(@$edges, $e, 1);

	# Delete keys
	my $outkey = $edge->outkey();
	my $inkey = $edge->inkey();
	foreach my $key (
			(map {$outkey . $_} @{$edge->outArray()}),
			(map {$inkey . $_} @{$edge->inArray()})) {
		$self->del_key($key, $edge);
	}

	# Delete crossings
	my $crossings = $self->var('crossings');
	my $edge_crossings = $crossings->{$edge};
	foreach my $e (@$edge_crossings) {
		$crossings->{$e} = [
			grep {$edge ne $_} @{$crossings->{$e}} ];
	}
	delete $crossings->{$edge};
} 

## ------------------------------------------------------------
##  auto-inserted from: Alignment/del_key.pl
## ------------------------------------------------------------

sub del_key {
	my $self = shift;
	my $key = shift;
	my $edge = shift;

	# Get array
	my $nodes = $self->var('nodes');
	my $array = [ 
		grep {$_ ne $edge} 
			@{$self->node($key)}
		];
	
	# Update nodes hash
	if (@$array) {
		$nodes->{$key} = $array;
	} else {
		delete $nodes->{$key};
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/del_node.pl
## ------------------------------------------------------------

sub del_node {
	my $self = shift;
	my $ref = shift;

	# Find node and key
	if ($ref =~ /^([a-z])(-?[0-9]+)$/) {
		my $key = $1;
		my $node = $self->rel2abs($key, $2);

		# Process all edges
		my $edges = $self->{'edges'};
		for (my $i = 0; $i < scalar(@$edges); ++$i) {
			my $edge = $edges->[$i];
			
			# Find nodes to match
			my $nodes = [];
			if ($edge->inkey() eq $key) {
				$nodes = $edge->inArray();
			} elsif ($edge->outkey() eq $key) {
				$nodes = $edge->outArray();
			}

			# Delete edge if there is a matching node
			if (grep {$_ eq $node} @$nodes) {
				$self->del_edge($i);
				--$i;
			}
		}
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/delete_creator.pl
## ------------------------------------------------------------

sub delete_creator {
	my $self = shift;
	my $creator1 = shift || -100;
	my $creator2 = shift || $creator1;

    # Delete all edges with given creator interval
    my $edges = $self->edges();
    for (my $e = 0; $e < scalar(@$edges); ++$e) {
        # Delete all automatically created edges
        my $edge = $edges->[$e];
		my $creator = $edge->creator();
        if ($creator1 <= $creator && $creator <= $creator2) {
            # Delete edge and decrement edge counter
            $self->del_edge($e);
            --$e;
        }
    }
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/edge.pl
## ------------------------------------------------------------

sub edge {
	my $self = shift;
	my $e = shift;
	return $self->var('edges')->[$e];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/edge_in_autowindow.pl
## ------------------------------------------------------------

sub edge_in_autowindow {
	my ($self, $edge) = @_;

	# Check whether boundary exists
	my $boundary = $self->var('autoalign');
	return 1 if (! $boundary);

	# Check whether edge is in range
	my ($outkey, $o1, $o2, $inkey, $i1, $i2) = @$boundary;
	my $ein = $edge->inArray();
	my $eout = $edge->outArray();
	my $imin = $ein->[0];
	my $imax = $ein->[$#$ein];
	my $omin = $eout->[0];
	my $omax = $eout->[$#$eout];

	return 
		($edge->inkey() ne $inkey ||
			($edge->inkey() eq $inkey && $i1 <= $imin && $imax <=
			$i2))
		&& ($edge->outkey() ne $outkey ||
			($edge->outkey() eq $outkey && $o1 <= $omin && $omax <= $o2));

	# Return 0 by default
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/edges.pl
## ------------------------------------------------------------

sub edges {
	my $self = shift;
	return $self->var('edges', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/erase_all.pl
## ------------------------------------------------------------

sub erase_all {
	my $self = shift;
	my $alexicon = $self->alexicon();
	my $graphs = $self->graphs();

	$self->clear();
	$self->alexicon($alexicon);
	$self->graphs($graphs);
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/exclude.pl
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
##  auto-inserted from: Alignment/extract_translex.pl
## ------------------------------------------------------------

# $self->extract_translex($interpreter): extract transfer lexicon
# rules and store them in interpreter's transfer lexicon 

my $debug = 0;

sub extract_translex {
	# Parameters
	my ($self, $interpreter) = @_;

	# Translation units hash
	my $tunits = {};

	# Merge all word-aligned nodes
	print "Merge alignment edges\n" if ($debug);
	$self->merge_alignments($tunits);

	# Merge cycles for each tunit in $tunits
	print "Merge components\n" if ($debug);
	foreach my $n (map {$_->[0]} uniq(sort(values(%$tunits)))) {
		# Merge component involving the first node $n in each tunit
		$self->tunit_merge_component($tunits, $n);
	}

	# Process tunits in bottom-up order. Note: the tunit graph is
	# guaranteed to be acyclic now, so bottom-up order makes sense!
	# Tunits are referred to by means of the first node in the tunit.
	my $done = {};
	my @todo = uniq(sort(map {$_->[0]} values(%$tunits)));
	while (@todo) {
		# Take off most recent node from stack 
		my $n = pop(@todo);
		my $tunit = $tunits->{$n};
		my $tunit_str = tunit2str($tunits->{$n});

		# Debug
		print "Process ", int2str($n), ":\n" if ($debug);

		# Skip tunit if already finally done
		next() if (($done->{$tunit_str} || 0) & 2);

		# Mark tunit as visited
		$done->{$tunit_str} = 1;

		# Find all unprocessed child tunits in the tunit DAG 
		my @children 
			= uniq(sort(
				map {$tunits->{$_}[0]} 
					$self->tunit_dependents($tunits, $n)));
		my @unprocessed 
			= grep {! $done->{tunit2str($tunits->{$_})}} 
				@children;

		# Debug
		print "    children: ",
			join(" ", map {int2str($_)} @children), "\n" if ($debug);
		print "    unprocessed: ",
			join(" ", map {int2str($_)} @unprocessed), "\n" if ($debug);


		# Process all unprocessed child tunits first
		if (@unprocessed) {
			# Add $n with child tunits to stack
			push @todo, ($n, @unprocessed);
		} else {
			print "    merge non-connected components of ", 
				int2str($n), "\n" if ($debug);
			# 0. Merge all non-connected components of $n: For each
			# root node within the component, compute the upwards path
			# to the external root; find the common root path shared by
			# all internal roots, and merge the component with 
			# all non-common nodes on the root path.
			my $paths = {};
			my $shared_path = undef;
			foreach my $nu (@{$tunits->{$n}}) {
				# Compute root path for node $nu
				my $rootpath = $paths->{$nu} = [$self->node_rootpath($nu)];
				print "rootpath($nu): ", join(" ", @$rootpath), "\n"
					if ($debug);
				$shared_path = $rootpath 
					if (! defined($shared_path));

				# Intersect shared path with new root path
				for (my $i = 0; $i <= min($#$rootpath, 
						$#$shared_path); ++$i) {
					if ($rootpath->[$i] != $shared_path->[$i]) {
						$shared_path = [$shared_path->[0..($i-1)]];
					}
				}
			}

			# Compute union of last node in shared path and all
			# rootpaths minus shared path
			my $shared_length = scalar(@$shared_path);
			my $tomerge = {};
			foreach my $nu (@{$tunits->{$n}}) {
				# Add all non-shared nodes in path to $tomerge
				my $rootpath = $paths->{$nu};
				for (my $i = $#$shared_path; $i <= $#$rootpath; ++$i) {
					$tomerge->{$rootpath->[$i]} = 1;
				}
			}
			print "shared: ", $shared_length, "\n"
				if ($debug);

			# Merge all nodes in $tomerge
			foreach my $newnode (keys(%$tomerge)) {
				#merge_tunit($tunits, $n, $newnode);
			}

			print "    merge governors of ", int2str($n), "\n" if ($debug);
			## 1. Merge all governors of $n: First find all governors
			## of $n ...
			my @governors = uniq(sort(
				map {$tunits->{$_}[0]}
					$self->tunit_governors($tunits, $n)));
			print "    governors: ",
				join(" ", map {int2str($_)} @governors), "\n" if ($debug);

			# ... then merge them if there is more than one ...
			my $governor1 = pop(@governors);
			foreach my $governor2 (@governors) {
				merge_tunit($tunits, $governor1, $governor2);
			}

			# ... and finally merge all cycles at the merged governors
			# so that the tunits graph remains acyclic.
			$self->tunit_merge_component($tunits, $governor1) if (@governors);


			## 2. Merge $n with its governor if $n is a monolingual
			## complement
			if ($self->tunit_is_monolingual($tunits, $n)) {
				print "    merge monolingual complement governor of ", 
					int2str($n), "\n" if ($debug);

				# Find any complement governors of the monolingual 
				# tunit $n ...
				my @cgovernors = uniq(sort(
					map {$tunits->{$_}[0]}
						$self->tunit_complement_governors($tunits, $n)));

				# ... then merge $n with its complement governors (if
				# there are any) ...
				foreach my $cgovernor (@cgovernors) {
					merge_tunit($tunits, $n, $cgovernor);
				}

				# ... and finally merge all cycles at the merged governors
				# so that the tunits graph remains acyclic.
				$self->tunit_merge_component($tunits, $n) if (@cgovernors);
			}

			## 3. Mark tunit as finally done
			$done->{$tunit_str} = 3;
		}
	}

	# Debugging output
	if (1 || $debug)  {
		# Print translation units
		print "\nTRANSLATION UNITS\n";
		my @sets = ();
		foreach my $tunit (uniq(sort(values(%$tunits)))) {
			push @sets, join(" ", sort(
				map {int2str($_)} @$tunit));
		}
		print join("\n", sort(@sets)), "\n";
		$interpreter->{'tunits'} = $tunits;
	}

	# Print lexicon
	# ved(X:subj, at:dobj(Y)) <=> know(X:subj, about:pobj(Y))
	if (1 || $debug) {
		$| = 1;
		print "\nTRANSFER RULES\n";
		foreach my $tunit (uniq(sort {$b->[0] <=> $a->[0]} (values(%$tunits)))) {
			# Print transfer unit frames
			my $trule = $self->tunit_cframe_print($tunits, $tunit);
			print "comp[", int2str($tunit->[0]), "]: ",
				$trule, "\n" if (defined $trule);

			# Print transfer adjunct frames

			# Print transfer deletion frames
			
			# Print transfer addition frames
		}
	}
}

sub tunit_cframe_print {
	# Parameters
	my ($self, $tunits, $tunit, $format) = @_;
	$format = 'txt' if (! $format);

	# Find and name variables of tunit
	my $variables = {};
	
	# Find source and target nodes, and exit if one set is empty
	my @snodes = grep {$_ > 0} @$tunit;
	my @tnodes = grep {$_ < 0} @$tunit;
	return undef unless (@snodes && @tnodes);
	 
	# Find dependency structure of the two units
	my $sourcetree = $self->tunit_deptree($tunits, $variables, $format,
		{}, @snodes);
	my $targettree = $self->tunit_deptree($tunits, $variables, $format,
		{}, @tnodes);
	
	# Return cframe
	return (scalar(@$tunit) + 2 * scalar(keys(%$variables))) . " " 
		. $sourcetree . " <=> " . $targettree;
}

sub tunit_deptree {
	# Parameters
	my ($self, $tunits, $variables, $format, $trees, @nodes) = @_;

	# Process all nodes in $nodes
	foreach my $n (@nodes) {
		# Only process each node once
		next() if ($trees->{$n});
		my $n0 = $tunits->{$n}[0];

		# Mark node as visited (will never be used except in cycles)
		$trees->{$n} = "***CYCLE***";

		# Find graph, node, and string
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		my $string = $nodeobj->input();

		# Process all dependent edges of node
		my @args = ();
		foreach my $e (sort {$a->in() <=> $b->in()} @{$nodeobj->out()}) {
			# Ignore non-dependents
			next() if (! $graph->is_dependent($e));

			# Find dependent id
			my $d = node2int($e->in(), $key);
			my $d0 = $tunits->{$d}[0];

			# Process dependent
			if ($tunits->{$n} eq $tunits->{$d}) {
				# Nodes $n and $d belong to the same tunit:
				# recursively process the dependent $d
				$self->tunit_deptree($tunits, $variables, $format,
					$trees, $d);

				# Add dependent to arg-list
				push @args, $e->type() . "=" . $trees->{$d};
			} elsif (grep {$_ == $n0}
					$self->tunit_complement_governors($tunits, $d)) {
				# Dependent is a tunit argument: create new variable
				# if necessary
				if (! $variables->{$d0}) {
					# Add new variable
					$variables->{$d0} = varname($variables);
				}

				# Add dependent to arg-list
				push @args, $e->type() . "=" . $variables->{$d0};
			} 

		}

		# Now create string representation of $n
		$trees->{$n} = lc($string) . 
			(@args ? "(" . join(", ", @args) . ")" : "");
	}

	# Return string representation of root node (=longest string in
	# $trees)
	my @strings = sort {length($b) <=> length($a)} values(%$trees);
	#print "    strings: ", join(" ", @strings), "\n";
	return $strings[0];
}

sub varname {
	my $hash = shift;
	return chr(scalar(keys(%$hash)) + 65);
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/file.pl
## ------------------------------------------------------------

=item $alignment->file($file) = $file

Get/set file associated with alignment.

=cut

sub file {
	my $self = shift;
	return $self->var('_file', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/fpsfile.pl
## ------------------------------------------------------------

=item $graph->fpsfile($fpsfile) = $fpsfile

Get/set follow postscript file associated with graph.

=cut

sub fpsfile {
	my $self = shift;
	my $key = shift;
	$key = "" if (! defined($key));
	return $self->var('fpsfile' . $key, @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/graph.pl
## ------------------------------------------------------------

sub graph {
	my $self = shift;
	my $key = shift;
	$key = "" if (! defined($key));
	return $self->{'graphs'}{$key};
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/graphs.pl
## ------------------------------------------------------------

sub graphs {
	my $self = shift;
	return $self->var('graphs', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/id.pl
## ------------------------------------------------------------

sub id {
	my $self = shift;
	return "A[" . $self->{'id'} . "]";
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/imax.pl
## ------------------------------------------------------------

sub imax {
	my $self = shift;
	my $key = shift;
	$self->{'imax'}{$key} = shift if (@_);
	return $self->{'imax'}{$key};
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/imin.pl
## ------------------------------------------------------------

sub imin {
	my $self = shift;
	my $key = shift;
	$self->{'imin'}{$key} = shift if (@_);
	return $self->{'imin'}{$key};
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/include.pl
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
##  auto-inserted from: Alignment/int2node.pl
## ------------------------------------------------------------

# convert integer to key and node
sub int2node {
	my ($int) = @_;
	return (abs($int) - 1, $int > 0 ? "a" : "b");
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/int2str.pl
## ------------------------------------------------------------

# convert integer to node string
sub int2str {
	my ($int) = @_;
	return ($int > 0 ? "a" : "b") . (abs($int) - 1), 
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/interpreter.pl
## ------------------------------------------------------------

sub interpreter {
	my $self = shift;
	return $self->{'interpreter'};
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/is_alignment.pl
## ------------------------------------------------------------

sub is_alignment {
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/is_graph.pl
## ------------------------------------------------------------

sub is_graph {
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/knode.pl
## ------------------------------------------------------------

=item $alignment->knode($key, $pos) = $node

Return node $node at node position $pos with key $key.

=cut

sub knode {
	my $self = shift;
	my $key = shift;
	my $i = shift;
	my $graph = $self->graph($key);
	return defined($graph) ? $graph->knode("", $i) : undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/merge_alignments.pl
## ------------------------------------------------------------

# Merge all nodes on each alignment edge
sub merge_alignments {
	# Parameters
	my ($self, $tunits) = @_;

	# Merge all nodes on each alignment edge
	foreach my $aedge (@{$self->edges()}) {
		my @nodes = ();
		
		# Compute innodes
		foreach my $n (@{$aedge->inArray()}) {
			push @nodes, node2int($n, $aedge->inkey());
		}

		# Compute outnodes
		foreach my $n (@{$aedge->outArray()}) {
			push @nodes, node2int($n, $aedge->outkey());
		}

		# Merge all nodes
		my $n0 = shift(@nodes);
		foreach my $n (@nodes) {
			merge_tunit($tunits, $n0, $n);
		}
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/merge_tunit.pl
## ------------------------------------------------------------

sub merge_tunit {
	my ($tunits, $n1, $n2) = @_;

	# Get tunits to merge
	my $tunit1 = $tunits->{$n1};
	my $tunit2 = $tunits->{$n2};

	# Initialize with default value if undefined
	$tunit1 = $tunits->{$n1} = [$n1] if (! defined $tunit1);
	$tunit2 = $tunits->{$n2} = [$n2] if (! defined $tunit2);

	# Return empty list if the two nodes have been merged already
	return() if ($tunit1 eq $tunit2 || $n1 == $n2);

	# Compute dead tunits
	my @dead = (tunit2str($tunit1), tunit2str($tunit2));

	# Ensure tunit1 has more elements than tunit2 by swapping, if necessary
	if ($#$tunit1 < $#$tunit2) {
		$tunit1 = $tunit2;
		$tunit2 = $tunits->{$n1};
	}

	# Append $tunit2 to $tunit1
	push @$tunit1, @$tunit2;

	# Change all references from tunit2 to tunit1
	foreach my $n (@$tunit2) {
		$tunits->{$n} = $tunit1;
	}

	# Debug
	if ($debug) {
		print "    merged ", join(" ", 
			map {int2str($_)} @$tunit1), 
			"\n";
	}

	# Return 1
	return @dead;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/minmax.pl
## ------------------------------------------------------------

sub min {
	my $min = shift;
	my $next;
	while (@_) {
		$min = $_[0] if (defined($_[0]) && ((! defined($min)) || $min > $_[0]));
		shift();
	}
	return $min;
}

sub max {
	my $max = shift;
	while (@_) {
		$max = $_[0] if (defined($_[0]) && ((! defined($max)) || $max < $_[0]));
		shift();
	}
	return $max;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/mtime.pl
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
##  auto-inserted from: Alignment/new.pl
## ------------------------------------------------------------

=item Alignment->new() = $align

Create new Alignment object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $interpreter = shift;

	# Create self: 
	my $self = { 
		'id' => ++$DTAG::Interpreter::graphid,
		'compounds' => {},
		'interpreter' => $interpreter
	};

	# Specify class for new object
	bless ($self, $class);
	$self->clear();

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: Alignment/new_crossings.pl
## ------------------------------------------------------------

sub new_crossings {
	my $self = shift;
	my $newedge = shift;

	# Find keys
	my $inkey = $newedge->inkey();
	my $ingraph = $self->graph($inkey);

	# Find first edge $before entirely before $newedge
	my $before;
	for (my $i = min(@{$newedge->inArray()}) - 1; $i >= 0 && ! $before; --$i) {
		foreach my $e (@{$self->node($inkey, $i)}) {
			if ($e->before($newedge)) {
				$before = $e;
				last();
			}
		}
	}

	# Find first edge $after entirely after $newedge
	my $after;
	my $imax = $ingraph->size();
	for (my $i = max(@{$newedge->inArray()}) + 1; 
			($i < $imax  && ! $after); ++$i) {
		foreach my $e (@{$self->node($inkey, $i)}) {
			if ($e->after($newedge)) {
				$after = $e;
				last();
			}
		}
	}

	# Initialize list of candidates for crossings
	my $candidates = [
		@{$before ? $self->crossings($before) : []},
		@{$after ? $self->crossings($after) : []}
	];

	# Add all edges between $before and $after to candidate list
	my $i1 = $before ? min(@{$before->inArray()}) : 0;
	my $i2 = $after ? max(@{$after->inArray()}) : $ingraph->size() - 1;
	for (my $i = $i1; $i <= $i2; ++$i) {
		push @$candidates,
			@{$self->node($inkey, $i)};
	}
	
	# Examine all candidate edges
	my $crossing = {};
	foreach my $edge (@$candidates) {
		$crossing->{$edge} = $edge
			if ($edge->crossing($newedge) && $edge ne $newedge);
	}

	# Return crossing edges
	return [ values(%$crossing) ];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/node.pl
## ------------------------------------------------------------

sub node {
	my $self = shift;
	my $key = shift || "";
	my $node = shift;
	$node = "" if (! defined($node));

	return $self->var('nodes')->{"$key$node"} || [];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/node2int.pl
## ------------------------------------------------------------

# Convert (key,node) to integer ID
sub node2int {
	my ($node, $key) = @_;
	return ($key eq "a" ? 1 : -1) * ($node + 1);
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/node_adjuncts.pl
## ------------------------------------------------------------

# Find adjuncts of node
sub node_adjuncts {
	# Parameters
	my $self = shift;

	# Process nodes
	my @adjuncts = ();
	foreach my $n (@_) {
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		foreach my $e (@{$nodeobj->out()}) {
			push @adjuncts, node2int($e->out(), $key)
				if ($graph->is_adjunct($e));
		}
	}

	# Return adjuncts
	return uniq(sort(@adjuncts));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/node_complement_governors.pl
## ------------------------------------------------------------

# Find complement governors for node
sub node_complement_governors {
	# Parameters
	my $self = shift;

	# Process nodes
	my @governors = ();
	foreach my $n (@_) {
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		foreach my $e (@{$nodeobj->in()}) {
			push @governors, node2int($e->out(), $key)
				if ($graph->is_complement($e));
		}
	}

	# Return governors
	return uniq(sort(@governors));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/node_complements.pl
## ------------------------------------------------------------

# Find complements of node
sub node_complements {
	# Parameters
	my $self = shift;

	# Process nodes
	my @complements = ();
	foreach my $n (@_) {
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		foreach my $e (@{$nodeobj->out()}) {
			push @complements, node2int($e->in(), $key)
				if ($graph->is_complement($e));
		}
	}

	# Return complements
	return uniq(sort(@complements));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/node_dependents.pl
## ------------------------------------------------------------

# node_dependents($self, @nodes) = @dependents
# 	- find dependents of node

sub node_dependents {
	# Parameters
	my $self = shift;

	# Process nodes
	my @dependents = ();
	foreach my $n (@_) {
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		foreach my $e (@{$nodeobj->out()}) {
			push @dependents, node2int($e->in(), $key)
				if ($graph->is_dependent($e));
		}
	}

	# Return governors
	return uniq(sort(@dependents));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/node_edges.pl
## ------------------------------------------------------------

sub node_edges {
	my $self = shift;
	my $key = shift;
	my $node = shift;
	
	# Find all edges containing node
	my $edges = $self->edges();
	my $node_edges = [];
	for (my $e = 0; $e < scalar(@$edges); ++$e) {
		my $edge = $edges->[$e];
		push @$node_edges, $e
			if ($edge->contains($key, $node));
	}

	# Return edge list
	return $node_edges;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/node_governors.pl
## ------------------------------------------------------------

# Find governors for node
sub node_governors {
	# Parameters
	my $self = shift;

	# Process nodes
	my @governors = ();
	foreach my $n (@_) {
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		foreach my $e (@{$nodeobj->in()}) {
			push @governors, node2int($e->out(), $key)
				#if ($graph->is_dependent($e));
				if (1);
		}
	}

	# Return governors
	return uniq(sort(@governors));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/node_in_autowindow.pl
## ------------------------------------------------------------

sub node_in_autowindow {
	my ($self, $key, $node) = @_;

	# Check whether boundary exists
	my $boundary = $self->var('autoalign');
	return 1 if (! $boundary);

	# Check whether node is in range
	my ($outkey, $o1, $o2, $inkey, $i1, $i2) = @$boundary;
	if ($key eq $outkey) {
		return $o1 <= $node && $node <= $o2;
	} elsif ($key eq $inkey) {
		return $i1 <= $node && $node <= $i2;
	}

	# Return 0 by default
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/node_incomplete.pl
## ------------------------------------------------------------

sub node_incomplete {
	my $self = shift;
	my $key = shift;
	my $i1 = shift || 0;

	# Find graph
	my $graph = $self->graph($key);

	# Go through all non-comment nodes in graph
	for (my $i = $i1; $i < $graph->size(); ++$i) {
		return $i if (! ($graph->node($i)->comment()
			|| (grep {$_->creator() > -100} @{$self->node($key, $i)})));
	}

	# No node found: return last node in graph
	return $graph->size() - 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/node_rootpath.pl
## ------------------------------------------------------------

# Find root path for node
sub node_rootpath {
	# Parameters
	my ($self, $node) = @_;

	# Calculate governors
	my @governors = $self->node_governors($node);
	print "    governors($node): ", join(" ", @governors), "\n";

	# Process governors
	if (scalar(@governors) == 0) {
		# Root node: return node alone
		return ($node);
	} elsif (scalar(@governors) == 1) {
		# Single governor: return concatenation of governor path and
		# governor
	} else {
		# More than one governor: return first governor path and print
		# error
		print "ERROR: node $node has multiple governors ",
			join(" ", @governors), ": ignoring all other than the first\n";
	}

	# Return
	return ($self->node_rootpath($governors[0]), $node);
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/offset.pl
## ------------------------------------------------------------

sub offset {
	my $self = shift;
	my $key = shift;

	# Set offset, if requested
	$self->{'offsets'}{$key} = min(shift() || 0,
		$self->graph($key)->size()-1) if (@_);

	# Get offset
	return $self->{'offsets'}{$key} || 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/ok.pl
## ------------------------------------------------------------

sub ok {
	my $self = shift;

	# Return false (0) if no learner is associated with alignment
	return 0 if (! $self->alexicon());

	# Pass on ok to learner
	$self->alexicon()->ok($self);

	# Auto-adjust offsets
	$self->auto_offset();

	# Return true: ok operation succeeded
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/postscript.pl
## ------------------------------------------------------------

=item $align->postscript() = $postscript

Return PostScript representation $postscript for alignment graph.

=cut


sub postscript {
	my $self = shift;
	my $interpreter = shift;

	# Variables
	my $node_edges = $self->var('nodes');
	my $nodes = { };
	my $ps = "% Nodes\n";
	my $setup = " ";

	# Boundaries
	my $boundaries = $self->var('autoalign') || [];
	my ($outkey, $o1, $o2, $inkey, $i1, $i2) = @$boundaries;

	# Draw nodes in each graph and number them
	my $node = 0;
	my $left = 0;
	foreach my $g (sort(keys(%{$self->graphs()}))) {
		# Create new column
		$ps .= "\n% Column $g\nnewcolumn\n";

		# Find graph object
		my $graph = $self->var('graphs')->{$g};
		if (! $graph) {
			DTAG::Interpreter::error("non-existent graph for key $g");
			next();
		}

		# Process all included nodes in graph
		my $onode = $node;
		my $imin = $self->var('imin')->{$g} || 0;
		my $imax = $self->var('imax')->{$g} || ($graph->size() - 1);
		for (my $i = $imin; $i <= $imax; ++$i) {
			my $nodeobj = $graph->node($i);
			my $r = $self->abs2rel($g, $i);
			if ($nodeobj && ! $nodeobj->comment()) {
				# Add node to graph
				$nodes->{"$g$i"} = $node++;
				my $label = $self->var("compounds")->{$g . $i} 
					|| $nodeobj->var("compound") 
					|| $nodeobj->var("romanized") 
					|| $nodeobj->input() || "";
				my $format = "";
				my $nedges = $node_edges->{"$g$i"};
				$format = " 3" if (! ( defined($nedges) && @$nedges));
				$format = " 4" if (! $self->node_in_autowindow($g, $i));
				$label = $left ? "$g$r    $label" : "$label    $g$r";
				$ps .= psstr($label) . "$format node\n";
			}
		}

		# Count number of nodes in column
		$setup .= ($node-$onode) . " ";
		$left = 1;
	}

	# Make setup
	my $title = $self->var('title') || "";
	$ps = "% Setup graph\n[$setup] setup\n" 
		. "/title {($title) 6} def\n\n"
		. "/formats [{1 0 0 setrgbcolor}\n"
		. "\t{0 0 1 setrgbcolor}\n"
		. "\t{1 0 0 setrgbcolor 1 setfontstyle setupfont}\n"
		. "\t{0.8 setgray}\n"
		. "\t{1 0.5 0.5 setrgbcolor}\n"
		. "\t{1 setfontstyle setupfont}\n"
		. "] def\n\n"
		. $ps . "\n% Edges\n";

	# Draw alignment edges
	foreach my $edge (@{$self->{'edges'}}) {
		my $type = $edge->type();
		my $inps = enodes($nodes, $edge->inArray(), $edge->inkey());
		my $outps = enodes($nodes, $edge->outArray(), $edge->outkey());
		my $creator = $edge->creator();
		my $format = "";
		$format = " 1" if ($creator == -100);
		$format = " 2" if ($creator >= 0);
		$format = " 5" if ($creator <= -101);
		$format = " 4" if (! $self->edge_in_autowindow($edge));
		$format = $edge->format() if (defined($edge->format()));

		if (defined($inps) && defined($outps)) {
			$ps .=  "$inps $outps" . psstr($type || "") . "$format edge\n";
		} else {
			# Ignore edge silently
			# DTAG::Interpreter::warning("illegal edge " .  $edge->string());
		}
	} 

	# Return entire PostScript file
	return $psheader->{'align'}
		. $ps . "\n" . $pstrailer->{'align'};
}

sub enodes {
	my $nodes = shift;
	my $enodes = shift;
	my $key = shift;
	my $s = "";

	# Compute PostScript representation of $enodes
	my $ok = 1;
	my $ps = join(" ", 
		map {
			my $node = $nodes->{"$key$_"}; 
			return undef if (! defined($node));
			$node;
		} @$enodes);

	# Return list or integer, as appropriate
	return scalar(@$enodes) == 1 ? $ps : "[$ps]";
} 

sub psstr {
	my $input = shift;
	$input = "" if (! defined($input));
	$input =~ s/\)/\\\)/;
	$input =~ s/\(/\\\(/;
	$input =~ s/\&gt;/>/;
	$input =~ s/\&lt;/</;

	return "(" . $input . ")";
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/print_graph.pl
## ------------------------------------------------------------

sub print_graph {
	my $self = shift;
	my $id = shift;
	my $index = shift;
	
	my $s = sprintf '%sA%-3d file=%s (%s) %s' . "\n",
		($index - 1 == ($id || 0) ? '*' : ' '),
		$index, 
		($self->file() || '*untitled*'),
		$self->id(),
		($self->mtime() ? 'modified ' : 'unmodified');
	
	foreach my $key (sort(keys(%{$self->{'graphs'}}))) {
		my $graph = $self->{'graphs'}{$key};
		$s .= "      $key [" . ($graph->file() || ""). "]: \""
			. $graph->text(' ', 30) . "\"\n";
	}

	return $s;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/print_osdt.pl
## ------------------------------------------------------------

sub print_osdt {
	my $self = shift;
	my $id = shift;
	my $index = shift;
	
	# Find source and target graphs
	my $sgraph = $self->{'graphs'}{"a"};
	my $tgraph = $self->{'graphs'}{"b"};
	my $snodes = {};
	my $tnodes = {};

	# Encode source graph
	my $source = $sgraph->print_osdt("source: ", 0, 0, $snodes);
	my $views = $snodes->{'_views'};
	my $nodes = $snodes->{'_nodes'};
	my $target = $tgraph->print_osdt("target: ", $views, $nodes, $tnodes);
	$views = $tnodes->{'_views'};
	$nodes = $tnodes->{'_nodes'};

	# Encode target graph
	my $s = $source . $target . "LAYER" . $views++ . " \"word alignments\" 0=\"type\" 1=\"creator\"\n";

	foreach my $e(@{$self->edges()}) {
		my $type = $e->type();
		my $creator = $e->creator();
		$type = " 0=\"$type\"" if (defined($type));
		$creator = " 1=\"$creator\"" if (defined($creator));
		$s .= "  NODE" . $nodes++ . "$type$creator\n";

		# Find nodes
		my $enodes = [];
		foreach my $in (@{$e->inArray()}) {
			push @$enodes, ($e->inkey() eq "a") 
				? $snodes->{$in} : $tnodes->{$in};
		}
		foreach my $out (@{$e->outArray()}) {
			push @$enodes, ($e->outkey() eq "a") 
				? $snodes->{$out} : $tnodes->{$out};
		}
		$enodes = [uniq(sort(@$enodes))];

		# Print edges
		foreach my $enode (@$enodes) {
			$s .= "  EDGE " . ($nodes - 1) . "<" . "$enode\n";
		}
	}

	print $s;
	return $s;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/print_tables.pl
## ------------------------------------------------------------

sub print_tables {
	# Parameters
	my $self = shift;
	my $nodecount = shift || 0;
	my $nodeattributes = shift || [];
	my $edgeattributes = shift || [];
	my $globalvars = shift || {};
	my $nodes2id = shift || {};
	my $prefix = shift || "";

	# Specify node and edge attributes
	DTAG::Graph::add_attributes($nodeattributes, "id", "key");
	DTAG::Graph::add_attributes($edgeattributes, "in", "out", "key");

	# Convert dependency graphs in alignment
	my ($nodes, $edges) = ("", "");
	my @keys = sort(keys(%{$self->graphs()}));
	my $keysstring = $prefix . join("", @keys);
	foreach my $key (sort(keys(%{$self->graphs()}))) {
		# Count node and edge attributes
		my $nacount = scalar(@$nodeattributes);
		my $eacount = scalar(@$edgeattributes);

		# Find global node and edge attributes
		my $graph = $self->graph($key);
		$globalvars->{"node:key"} = $key;
		$globalvars->{"edge:key"} = $key;

		# Compute dependency graph tables
		my ($gnodes, $gedges, $gnodecount) = $graph->print_tables($nodecount, 
			$nodeattributes, $edgeattributes, $globalvars, $nodes2id,
			$prefix . "$key");

		# Update tables
		$nodes = add_na_columns($nodes, scalar(@$nodeattributes) - $nacount);
		$edges = add_na_columns($edges, scalar(@$edgeattributes) - $eacount);
		$nodes .= $gnodes;
		$edges .= $gedges;
		$nodecount = $gnodecount;
	}

	# Set file name
    $globalvars->{'node:file'} = $self->file()
        if ($self->file());

	# Convert all many-many alignment edges to formal alignment nodes
	# augmented by n-1 alignment edges
	$globalvars->{"node:key"} = undef;
	foreach my $aedge (@{$self->edges()}) {
		# Decompose alignment edge
		my ($inkey, $outkey) = ($aedge->inkey(), $aedge->outkey());
		my ($inprefix, $outprefix) = ($prefix . $inkey, $prefix . $outkey);
		my ($ingraph, $outgraph) = ($self->graph($inkey), $self->graph($outkey));
		my $innodes = $aedge->inArray();
		my $outnodes = $aedge->outArray();

		# Set variable values
		$globalvars->{'node:key'} = "$outkey->$inkey";
		$globalvars->{'node:id'} = $keysstring . $nodecount;
		$globalvars->{'node:line'} = $aedge->var("lineno");
		$globalvars->{'node:sentence'} = undef;
		$globalvars->{'node:token'} = undef;
		$globalvars->{'edge:key'} = "$outkey->$inkey";
		$globalvars->{'edge:label'} = $aedge->type();
		$globalvars->{'edge:primary'} = undef;

		# Create in-edges
		my $nedges = 0;
		$globalvars->{'edge:out'} = $globalvars->{'node:id'};
		foreach my $inode (@$innodes) {
			my $nodeid = $nodes2id->{$inprefix .  $inode};
			if (defined($nodeid)) {
				$globalvars->{'edge:in'} = $nodeid;
				$edges .= DTAG::Graph::create_R_table_row($edgeattributes, $aedge, $globalvars, 'edge:');
				++$nedges;
			} else {
				my $insign = signature($ingraph, $innodes, "_input");
				print "Undefined node " . $inprefix . $inode . " in "
					. $aedge->string() . " in " .  $globalvars->{"node:file"} . " with insign "
						. $insign . "\n"
					if ($insign !~ /^\s*<\/?[sS]>\s*$/);
			}
		}

   		# Create out-edges
		$globalvars->{'edge:in'} = $globalvars->{'node:id'};
		foreach my $onode (@$outnodes) {
			my $nodeid = $nodes2id->{$outprefix .  $onode};
			if (defined($nodeid)) {
				$globalvars->{'edge:out'} = $nodeid;
				$edges .= DTAG::Graph::create_R_table_row($edgeattributes, $aedge, $globalvars, 'edge:');
				++$nedges;
			} else {
				my $outsign = signature($outgraph, $outnodes, "_input");
				print "Undefined node " . $outprefix . $onode . " in "
					. $aedge->string() . " in " .  $globalvars->{"node:file"} . " with outsign "
						. $outsign . "\n"
					if ($outsign !~ /^<\/?[sS]>$/);
			}
		}

		# Create node
		if ($nedges > 0) {
			$nodes .= DTAG::Graph::create_R_table_row(
				$nodeattributes, $aedge, $globalvars, 'node:');
			++$nodecount;
		}
	}

	# Return
	return ($nodes, $edges, $nodecount, $nodeattributes, $edgeattributes);
}

sub add_na_columns {
    my $table = shift;
    my $n = shift || 0;
	return $table if ($n == 0 || length($table) == 0);
    my $columns = "\tNA" x $n;
    $table =~ s/$/$columns/g;
    return $table;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/psfile.pl
## ------------------------------------------------------------

=item $graph->psfile($psfile) = $psfile

Get/set PostScript file associated with graph.

=cut

sub psfile {
	my $self = shift;
	return $self->var('psfile', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/rel2abs.pl
## ------------------------------------------------------------

sub rel2abs {
	my $self = shift;
	my $key = shift;
	my $relative = shift;

	return $relative + ($self->{'offsets'}{$key} || 0);
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/shift_edges.pl
## ------------------------------------------------------------

sub shift_edges {
	my $self = shift;
	my $key = shift || "?";
	my $node = shift || 0;
	my $shift = shift || 0;

	# Test that alignment key $key is legal
	if (! exists($self->{'graphs'}{$key})) {
		error("illegal alignment file key $key");
		return undef;
	}

	# Shift alignment edges
	my $newedges = [];
	foreach my $edge (@{$self->edges()}) {
		my $newedge = $self->shift_edge($edge, $key, $node, $shift) || $edge;
		push @$newedges, $newedge;
	}

	# Create new graph
	$self->set_edges($newedges);
}

sub shift_edge {
	my $self = shift;
	my $oldedge = shift;
	my $skey = shift;
	my $snode = shift;
	my $shift = shift;

	# No changes so far
	my $changed = 0;

	# Clone edge
	my $edge = $oldedge->clone();

	# Determine whether in- and out-array should be shifted
	my @arrays = ();
	my $inarray = ($edge->inkey() eq $skey) ? $edge->inArray() : undef;
	my $outarray = ($edge->outkey() eq $skey) ? $edge->outArray() : undef;
	push @arrays, $inarray if ($inarray);
	push @arrays, $outarray if ($outarray);

	# Shift each array
	foreach my $array (@arrays) {
		# Shift each node in array
		for (my $i = 0; $i <= $#$array; ++$i) {
			if ($array->[$i] >= $snode) {
				$changed = 1;
				$array->[$i] += $shift;
			}
		}
	}

	# Save arrays
	$edge->inArray($inarray) if ($inarray);
	$edge->outArray($outarray) if ($outarray);
	
	# Return shifted $edge, or undef if unmodified
	return $changed ? $edge : undef;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/str2tunit.pl
## ------------------------------------------------------------

sub str2tunit {
	my $tunits = shift;
	my $str = shift;
	my ($n) = split(/ /, $str);
	return $tunits->{$n}
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/tarjan.pl
## ------------------------------------------------------------

# 	Finding strongly connected components (including cycles) with
# 	Tarjan's algorithm
#    
# 	DFS(G) {
# 		make a new vertex x with edges x => v for all v in G
# 		initialize a counter N to zero
# 		initialize list L to empty
# 		build directed tree T, initially a single vertex {x}
# 		visit(x)
#     }
# 
#     visit(p) {
# 		add p to L
# 		dfsnum(p) = N
# 		increment N
# 		low(p) = dfsnum(p)
# 		for each edge p->q
# 			if q is not already in T {
# 				add p->q to T
# 				visit(q)
# 				low(p) = min(low(p), low(q))
# 			} else low(p) = min(low(p), dfsnum(q))
# 
# 		if low(p)=dfsnum(p)
# 		{
# 			output "component:"
# 			repeat
# 				remove last element v from L
# 				output v
# 				remove v from G
# 			until v=p
# 		}
#     }

## ------------------------------------------------------------
##  auto-inserted from: Alignment/text.pl
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
##  auto-inserted from: Alignment/tunit2str.pl
## ------------------------------------------------------------

sub tunit2str {
	my $tunit = shift;
	return join(" ", sort(@$tunit));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/tunit_complement_governors.pl
## ------------------------------------------------------------

sub tunit_complement_governors {
	# Parameters
	my ($self, $tunits, $n) = @_;

	# Find current tunit
	my $tunit = $tunits->{$n};
	my $n0 = $tunit->[0];

	# Find all complement governor nodes 
	my $governors = {};
	foreach my $g ($self->node_complement_governors(@$tunit)) {
		# Find main node in tunit for $g
		my $g0 = $tunits->{$g}[0];

		# Add $g0 to governors set if $g0 is not in $tunit
		$governors->{$g0} = 1 if ($g0 != $n0);
	}

	# Return
	return sort(keys(%$governors));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/tunit_complements.pl
## ------------------------------------------------------------

sub tunit_complements {
	# Parameters
	my ($self, $tunits, $n) = @_;

	# Find current tunit
	my $tunit = $tunits->{$n};
	my $n0 = $tunit->[0];

	# Find all nodes that 
	my $dependents = {};
	foreach my $d ($self->node_complements(@$tunit)) {
		# Find main node in tunit for $d
		my $d0 = $tunits->{$d}[0];

		# Add $d0 to dependents set if $d0 is not in $tunit
		$dependents->{$d0} = 1 if ($d0 != $n0);
	}

	# Return
	return sort(keys(%$dependents));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/tunit_dependents.pl
## ------------------------------------------------------------

sub tunit_dependents {
	# Parameters
	my ($self, $tunits, $n) = @_;

	# Find current tunit
	my $tunit = $tunits->{$n};
	my $n0 = $tunit->[0];

	# Find all nodes that 
	my $dependents = {};
	foreach my $d ($self->node_dependents(@$tunit)) {
		# Find main node in tunit for $d
		my $d0 = $tunits->{$d}[0];

		# Add $d0 to dependents set if $d0 is not in $tunit
		$dependents->{$d0} = 1 if ($d0 != $n0);
	}

	# Return
	return sort(keys(%$dependents));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/tunit_governors.pl
## ------------------------------------------------------------

sub tunit_governors {
	# Parameters
	my ($self, $tunits, $n) = @_;

	# Find current tunit
	my $tunit = $tunits->{$n};
	my $n0 = $tunit->[0];

	# Find all governor nodes 
	my $governors = {};
	foreach my $g ($self->node_governors(@$tunit)) {
		# Find main node in tunit for $g
		my $g0 = $tunits->{$g}[0];

		# Add $g0 to governors set if $g0 is not in $tunit
		$governors->{$g0} = 1 if ($g0 != $n0);
	}

	# Return
	return sort(keys(%$governors));
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/tunit_is_monolingual.pl
## ------------------------------------------------------------

sub tunit_is_monolingual {
	# Parameters
	my ($self, $tunits, $n) = @_;
	my $tunit = $tunits->{$n};

	# Check whether tunit contains both signs
	my $np = 0;
	foreach my $n (@$tunit) {
		if ($n > 0) {
			$np |= 1;
		} else {
			$np |= 2;
		}
	}

	# Return result
	return $np == 3 ? 0 : 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/tunit_merge_component.pl
## ------------------------------------------------------------

sub tunit_merge_component {
	# Parameters
	my ($self, $tunits, $n) = @_;

	# Visit all nodes that transitively dominate $n depth-first, and
	# construct a reverse graph $revgraph of the subgraph consisting
	# of all edges that dominate $n. Visited nodes are indicated by bit
	# 1 in $visited.
	my $revgraph = {};
	my $visited = {};
	$self->tunit_upnodes_visit($tunits, $revgraph, $visited, $n);

	# Now visit all nodes that transitively dominate $n in the reverse
	# graph, depth-first. Visited nodes are indicated by bit 2 in
	# $visited.
	$self->tunit_upnodes_visit_reverse($tunits, $revgraph, $visited, $n);

	# The strongly connected component for $n consists of all nodes in
	# $visited that were visited in both the original graph and the
	# reverse graph. 
	my @component = grep {$visited->{$_} == 3} keys(%$visited);

	# Now merge all tunits in component
	foreach my $m (@component) {
		merge_tunit($tunits, $n, $m);
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/tunit_upnodes_visit.pl
## ------------------------------------------------------------

	sub tunit_upnodes_visit {
		my ($self, $tunits, $revgraph, $visited, $n) = @_;

		# Mark $n as visited
		$visited->{$n} |= 1;

		# Visit parents of $n and add parent edges to $revgraph
		foreach my $m ($self->tunit_governors($tunits, $n)) {
			# Add dominating edge to reverse graph
			$revgraph->{$m}{$n} = 1;

			# Visit $m if it has not been visited before
			$self->tunit_upnodes_visit($tunits, $revgraph, $visited, $m)
				if (! (($visited->{$m} || 0) & 1));
		}
	}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/tunit_upnodes_visit_reverse.pl
## ------------------------------------------------------------

	sub tunit_upnodes_visit_reverse {
		my ($self, $tunits, $revgraph, $visited, $n) = @_;

		# Mark $n as visited
		$visited->{$n} |= 2;

		# Visit parents of $n in reverse graph
		foreach my $m (keys(%{$revgraph->{$n}})) {
			# Visit $m if it has not been visited before
			$self->tunit_upnodes_visit_reverse($tunits, $revgraph, $visited, $m)
				if (! (($visited->{$m} || 0) & 2));
		}
	}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/uniq.pl
## ------------------------------------------------------------

sub uniq {
	my @result = ();
	my $last = undef;
	foreach (@_) {
		push @result, $_ 
			if (defined($_) && (! (defined($last) && $last eq $_)));
		$last = $_;
	}
	return @result;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/update.pl
## ------------------------------------------------------------

sub update {
	my $self = shift;

	# Activate autoaligner, if necessary
	my $alexicon = $self->alexicon();
	if ($alexicon && $self->var('autoalign')) {
		$alexicon->autoalign($self);
	}
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/var.pl
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
##  auto-inserted from: Alignment/write_atag.pl
## ------------------------------------------------------------

sub write_atag {
	my $self = shift;
	my $atag = "<DTAGalign>\n";
	
	# Print <alignFile> tags
	my $sign = {};
	foreach my $key (sort(keys(%{$self->{'graphs'}}))) {
		my $file = $self->{'graphs'}{$key}->file();
		$atag .= 
			"<alignFile key=\"$key\" href=\"$file\" sign=\"_input\"/>\n";
		$sign->{$key} = "_input";
	}

	# Print <align> tags
	foreach my $e (@{$self->{'edges'}}) {
		my $inkey = $e->inkey();
		my $outkey = $e->outkey();
		my $type = $e->type();
		my $ingraph = $self->{'graphs'}{$inkey};
		my $outgraph = $self->{'graphs'}{$outkey};

		$atag .= 
			'<align out="'
					. join(" ", map {$outkey . $_} @{$e->outArray()})
				. '" type="'
					. (defined($type) ? $type : "")
				. '" in="'
					. join(" ", map {$inkey . $_} @{$e->inArray()})
				. '" creator="'
					. $e->creator()
				. '" insign="'
					. signature($ingraph, $e->inArray(), $sign->{$inkey})
				. '" outsign="'
					. signature($outgraph, $e->outArray(), $sign->{$outkey})
				. '"'
				#. vars2xml($e->vars()) 
				. "/>\n";
	}

	# Print <compound> tags
	my $compounds = $self->{'compounds'};
	foreach my $c (sort(keys(%$compounds))) {
		$atag .= '<compound node="' . $c . '">' . $compounds->{$c}
			. "</compound>\n";
	}

	# Print end tag
	$atag .= "</DTAGalign>\n";

	# Return 
	return $atag;
}

sub vars2xml {
	my $vars;
	return "";
}

sub signature {
	my $graph = shift;
	my $nodes = shift;
	my $var = shift;

	my $signature = "";
	my $s = "";
	return join(" ",
		map {
			my $nodeobj = $graph->node($_);
			my $val = $nodeobj ? $nodeobj->var($var) || "÷" : "÷";
			$val = "$val" || "÷";
			$val =~ s/ /\&nbsp;/g;
			$val =~ s/"/&quot;/g;
			$val;
		} @$nodes);
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
##  start auto-insert from directory: AEdge
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
##  auto-inserted from: Alignment/AEdge/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 AEdge

=head2 NAME

AEdge - edge in alignment graph

=head2 DESCRIPTION

AEdge - edge in alignment graph.

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package AEdge;
use strict;



## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/after.pl
## ------------------------------------------------------------

sub after {
	my $self = shift;
	my $edge = shift;

	return $edge->before($self);
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/before.pl
## ------------------------------------------------------------

sub before {
	my $self = shift;
	my $edge = shift;

	# Return undef if edges do not have same out- and in-key
	return undef if ($self->outkey() ne $edge->outkey() 
		|| $self->inkey() ne $edge->inkey());

	# Return 0 if $self is entirely before $edge, 1 otherwise
	return (max(@{$self->outArray()}) < min(@{$edge->outArray()})
			&& max(@{$self->inArray()}) < min(@{$edge->inArray()}))
		? 1 : 0;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/clone.pl
## ------------------------------------------------------------

sub clone {
	my $self = shift;
	my $clone = AEdge->new();

	# Copy array
	for (my $i = 0; $i <= $#$self; ++$i) {
		$clone->[$i] = $self->[$i];
	}

	# Clone in and out arrays
	my $in = $self->in();
	my $out = $self->out();
	$clone->in(UNIVERSAL::isa($in, 'ARRAY') ? [@$in] : $in);
	$clone->out(UNIVERSAL::isa($out, 'ARRAY') ? [@$out] : $out);

	# Return clone
	return $clone;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/contains.pl
## ------------------------------------------------------------

sub contains {
	my $self = shift;
	my $key = shift;
	my $node = shift;

	# Check whether edge contains node
	if ($self->outkey() eq $key) {
		return 1 if (grep {$_ eq $node} @{$self->outArray()});
	} elsif ($self->inkey() eq $key) {
		return 1 if (grep {$_ eq $node} @{$self->inArray()});
	}
	
	# No match
	return 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/cost.pl
## ------------------------------------------------------------

sub alex {
	my $self = shift;
	$self->[7] = shift if (@_);
	return $self->[7];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/creator.pl
## ------------------------------------------------------------

# creator:
#	+n = user_id
#   -n = automatic confirmed n times
# 	-100 = automatic unconfirmed
#   -101 = hard default (only overridden by user)

sub creator {
	my $self = shift;
	$self->[6] = shift if (@_);
	return $self->[6] || 0;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/crossing.pl
## ------------------------------------------------------------

sub crossing {
	my $self = shift;
	my $edge = shift;

	# Return undef if edges do not have same out- and in-key
	return undef if ($self->outkey() ne $edge->outkey() 
		|| $self->inkey() ne $edge->inkey());

	# Return 0 if edges do not cross
	return 0 if ($self->before($edge) || $self->after($edge));
	
	# Return 1 if edges cross
	return 1;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/format.pl
## ------------------------------------------------------------

sub format {
	my $self = shift;
	$self->[8] = shift if (@_);
	return $self->[8];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/in.pl
## ------------------------------------------------------------

=item $edge->in($in) = $in

Get/set in-nodes $in of edge. 

=cut

sub in {
	my $self = shift;
	$self->[1] = shift if (@_);
	return $self->[1];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/inArray.pl
## ------------------------------------------------------------

sub inArray {
	my $self = shift;
	if (@_) {
		my $array = shift;
		$self->in(($#$array == 0) ? $array->[0] : $array);
	}

	my $in = $self->in();
	return UNIVERSAL::isa($in, "ARRAY") ? $in : [ $in ];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/inkey.pl
## ------------------------------------------------------------

=item $edge->inkey($inkey) = $inkey

Get/set inkey $inkey of edge. 

=cut

sub inkey {
	my $self = shift;
	$self->[0] = shift if (@_);
	return $self->[0];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/inside.pl
## ------------------------------------------------------------

sub inside { 
	my $self = shift;
	my $list = shift;
	my $from = shift;
	my $to = shift;

	# Return 1 if any node in list is inside the interval
	foreach my $node (@$list) {
		return 1 if ($from <= $node && $node <= $to);
	}

	# Return 0 otherwise
	return 0;
}

sub inside_in {
	my $self = shift;
	return $self->inside($self->inArray(), @_);
} 

sub inside_out {
	my $self = shift;
	return $self->inside($self->outArray(), @_);
} 


## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/minmax.pl
## ------------------------------------------------------------

sub min {
	my $min = shift;
	my $next;
	while (@_) {
		$min = $_[0] if (defined($_[0]) && ((! defined($min)) || $min > $_[0]));
		shift();
	}
	return $min;
}

sub max {
	my $max = shift;
	while (@_) {
		$max = $_[0] if (defined($_[0]) && ((! defined($max)) || $max < $_[0]));
		shift();
	}
	return $max;
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/new.pl
## ------------------------------------------------------------

=item Edge->new() = $edge

Create new edge $edge.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self: 0=inkey 1=in 2=outkey 3=out 4=type 5=tags 6=creator 7=alex 8=format
	my $self = [ @_ ];

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/out.pl
## ------------------------------------------------------------

=item $edge->out($out) = $out

Get/set out-node for edge.

=cut

sub out {
	my $self = shift;
	$self->[3] = shift if (@_);
	return $self->[3];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/outArray.pl
## ------------------------------------------------------------

sub outArray {
	my $self = shift;
    if (@_) {
    	my $array = shift;
    	$self->out(($#$array == 0) ? $array->[0] : $array);
	}
	my $out = $self->out();
	return UNIVERSAL::isa($out, "ARRAY") ? $out : [ $out ];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/outkey.pl
## ------------------------------------------------------------

=item $edge->outkey($outkey) = $outkey

Get/set outkey for edge.

=cut

sub outkey {
	my $self = shift;
	$self->[2] = shift if (@_);
	return $self->[2];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/signature.pl
## ------------------------------------------------------------

sub signature {
	my $self = shift;
	return $self->outkey() . scalar(@{$self->outArray})
		. $self->inkey() . scalar(@{$self->inArray}); 
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/string.pl
## ------------------------------------------------------------

sub string {
	my $self = shift;
	my $offsets = shift || {};

	# Get creator
	my $creator = $self->creator();
	my $ctext = "";
	$ctext = " (manually approved)" if ($creator < 0);
	$ctext = " (suggested by DTAG)" if ($creator == -100);
	$ctext = " (suggested by external aligner)" if ($creator <= -101);
	$ctext = " (manually created)" if ($creator >= 0);

	return 
		$self->outkey() . join("+", 
			map {$_ - ($offsets->{$self->outkey} || 0)} @{$self->outArray()}) 
		. " " . $self->type() . " "
		. $self->inkey() . join("+", 
			map {$_ - ($offsets->{$self->inkey} || 0)} @{$self->inArray()}) 
		. "   " . $ctext;
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/type.pl
## ------------------------------------------------------------

=item $edge->type($type) = $type

Get/set edge type.

=cut

sub type {
	my $self = shift;
	$self->[4] = shift if (@_);
	return $self->[4];
}

## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/var.pl
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
	if ($vars =~ /§$var=([^§]*)§/) {
		return $1 || "";
	} else {
		return undef;
	}
}


## ------------------------------------------------------------
##  auto-inserted from: Alignment/AEdge/vars.pl
## ------------------------------------------------------------

=item $edge->vars($vars) = $vars

Get/set variable string for edge, used for storing variable-value
pairs. 

=cut

sub vars {
	my $self = shift;
	$self->[5] = shift if (@_);
	return $self->[5] || "§";
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
##  stop auto-insert from directory: AEdge
## ------------------------------------------------------------


1;

