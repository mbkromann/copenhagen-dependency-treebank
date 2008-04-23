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
##  auto-inserted from: ALexicon/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 DTAG::ALexicon

=head2 NAME

DTAG::ALexicon - DTAG alignment lexicon

=head2 DESCRIPTION

DTAG::ALexicon - manipulating alignment lexicons

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package DTAG::ALexicon;
require DTAG::Interpreter;
use strict;

# Create new dummy lexical entry for identical words
my $alex_identity = ALex->new();
$alex_identity->out([]);
$alex_identity->in([]);
$alex_identity->type('');
$alex_identity->pos(1);
$alex_identity->neg(0);

# Create new dummy lexical entry for m-n aligned words
my $alex_parallel = ALex->new();
$alex_parallel->out([]);
$alex_parallel->in([]);
$alex_parallel->type('');
$alex_parallel->pos(1);
$alex_parallel->neg(0);

# Dummy subroutine always returning false
my $dummysub = sub {return 0};

# Maximal number of entries in hash before word is considered a
# function word
my $FUNCTIONWORD_MAXCOUNT = 500;


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/add_alex.pl
## ------------------------------------------------------------

sub add_alex {
	my $self = shift;
	my $out = shift;
	my $type = shift;
	my $in = shift;
	my $pos = shift;
	my $neg = shift || 0;

	# Check positive weight
	if ($pos < 0) {
		$neg = - $pos;
		$pos = 0;
	}

	# Lookup alex locally, and create it if necessary
	my $alex = $self->lookup_local($out, $type, $in);
	if (! $alex) {
		# Create alex
		$alex = ALex->new();
		$alex->out($out);
		$alex->type($type);
		$alex->in($in);
		$self->insert($alex);
	} 
	
	# Update weights
	$alex->incpos($pos);
	$alex->incneg($neg);

	# Return alex
	return $alex;
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/add_gaps.pl
## ------------------------------------------------------------

sub add_gaps {
	my $self = shift;
	my $type = shift;
	my $gaps = shift;
	my $count = shift || 1;

	# Process gaps
	my $gaplist = $self->gaps($type);
	foreach my $gap (@$gaps) {
		$gaplist->[$gap] = ($gaplist->[$gap] || 0) + $count;
	}

	# Update total number of gaps
	$self->var('total_gaps', 
		($self->var('total_gaps') || 0) + scalar(@$gaps));
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/alex.pl
## ------------------------------------------------------------

sub alex {
	my $self = shift;
	return $self->var('alex', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/autoalign.pl
## ------------------------------------------------------------

sub autoalign {
	my $self = shift;
	my $alignment = shift;

	# Options
	my $maxcross = 10;

	# Find keys
	my $outkey = "a";
	my $inkey = "b";
	my $outgraph = $alignment->graph($outkey);
	my $ingraph = $alignment->graph($inkey);

	# Read starting points
	my $window = $self->window();
	my $o1 = shift || $alignment->offset($outkey) || 0;
	my $i1 = shift || $alignment->offset($inkey) || 0;
	#print "autoalign[1]: o1=$o1 i1=$i1\n";
	$o1 = $outgraph->next_noncomment_node($o1)
		if ($outgraph->node($o1) && $outgraph->node($o1)->comment());
	$i1 = $ingraph->next_noncomment_node($i1)
		if ($ingraph->node($i1) && $ingraph->node($i1)->comment());
	#print "autoalign[2]: o1=$o1 i1=$i1\n";

	# Ensure that $o1 and $i1 are within legal range
	$o1 = max(0, min($o1, $outgraph->size() - 1));
	$i1 = max(0, min($i1, $ingraph->size() - 1));
	
	# Change offset in graph
	$alignment->offset($outkey, $o1);
	$alignment->offset($inkey, $i1);

	# Read ending points
	my $o2 = shift || $outgraph->next_noncomment_node($o1, $window) || 1e30;
	my $i2 = shift || $ingraph->next_noncomment_node($i1, $window) || 1e30;
	#print "autoalign[3]: o1=$o1 i1=$i1 o2=$o2 i2=$i2\n";

	# Ensure that $o2 and $i2 are within legal range
	$o2 = max(0, min($o2, $outgraph->size() - 1));
	$i2 = max(0, min($i2, $ingraph->size() - 1));
	
	# Store automatically modified interval in alignment
	$alignment->var('autoalign', [$outkey, $o1, $o2, $inkey, $i1, $i2]);
	#print "o1=$o1 o2=$o2 i1=$i1 i2=$i2\n";

	# Delete all unconfirmed automatic alignments
	my $edges = $alignment->edges();
	$alignment->delete_creator(-100, -100);

	# Find unaligned nodes in outgraph
	my $unaligned_out = [];
	for (my $o = $o1; $o <= $o2; ++$o) {
		push @$unaligned_out, $o
			if (! ($outgraph->node($o)->comment() ||
				scalar(
					#grep {$alignment->edge($_)->creator() > -100}
					@{$alignment->node_edges($outkey, $o)})));
	}

	# Find unaligned nodes in ingraph
	my $unaligned_in = [];
	for (my $i = $i1; $i <= $i2; ++$i) {
		push @$unaligned_in, $i
			if (! ($ingraph->node($i)->comment() ||
				scalar(
					#grep {$alignment->edge($_)->creator() > -100}
					@{$alignment->node_edges($inkey, $i)})));
	}

	# Print unaligned nodes
	# print "unaligned nodes: " . join(" ",
	#	(map {$outkey . $_} @$unaligned_out), 
	#	(map {$inkey . $_} @$unaligned_in)), "\n"; 

	# Lookup all alexes containing unaligned words
	my $unaligned_outw = [
		map {$outgraph->node($_)->input()} @$unaligned_out ];
	my $unaligned_inw = [
		map {$ingraph->node($_)->input()} @$unaligned_in ];
	my $alexes = $self->lookup_words($unaligned_outw, $unaligned_inw);
	
	# Generate all possible edges within window
	$edges = [];
	foreach my $alex (@$alexes) {
		#print "\n" . $alex->string() . "\n";

		# Find matching nodes in in- and out-graphs
		my $inmatches = $self->match_pattern($ingraph, 
			$unaligned_in, $alex->in());
		my $outmatches = $self->match_pattern($outgraph,
			$unaligned_out, $alex->out());

		# Create matching edges
		foreach my $innodes (@$inmatches) {
			foreach my $outnodes (@$outmatches) {
				# Create edge
				my $edge = AEdge->new();
				$edge->inkey($inkey);
				$edge->in($innodes);
				$edge->outkey($outkey);
				$edge->out($outnodes);
				$edge->type($alex->type());
				$edge->creator(-100);
				$edge->alex($alex);

				# Push edge onto edges
				push @$edges, $edge;
			}
		}
	}

	# Add edges for all identical words
	for (my $o = $o1; $o <=$o2; ++$o) {
		my $outnode = $outgraph->node($o) || next();
		my $outw = $outnode->input() || "";
		for (my $i = $i1; $i <= $i2; ++$i) {
			my $innode = $ingraph->node($i) || next();
			if ($outw eq ($innode->input() || "")) {
				# Create new edge for identical word pair if both
				# words are non-aligned
				if (scalar(@{$alignment->node_edges($outkey, $o)}) == 0
						&& scalar(@{$alignment->node_edges($inkey, $i)}) == 0) {
					my $aedge = AEdge->new();
					$aedge->inkey($inkey);
					$aedge->in([$i]);
					$aedge->outkey($outkey);
					$aedge->out([$o]);
					$aedge->type($alex_identity->type());
					$aedge->creator(-100);
					$aedge->alex($alex_identity);

					# Push edge onto edges
					push @$edges, $aedge;
				}
			}
		}
	}


	# Print edges
	#foreach my $edge (@$edges) {
	#	print "potential edge: " . $edge->string() . " " 
	#	. $edge->alex()->string() . "\n";
	#}

	# Make alignments greedily, starting with nodes with fewest 
	# overlapping edges and highest probability, until no more
	# compatible edges are left
	my $remaining = {};
	map {$remaining->{$_} = $_} @$edges;
	my $phase = 0;
	while (keys(%$remaining) || $phase < 1) {
		# Fill in alignments for parallel m-n sequences (enclosed by two
		# parallel edges) when all other edges have been used up
		if ($phase == 0 && ! keys(%$remaining)) {
			# Find all m-n sequences
			my ($o, $i) = (0, 0, 0, 0);
			my $last = AEdge->new();
			$last->out(0); $last->in(0); $last->type('');
			my $broken = 0;
			my $sequences = [];
			my $outnodes = [];
			my $innodes = [];
			while ($o <= $o2 && $i <= $i2) {
				# Find next out-edge
				while ($o <= $o2 && ($outgraph->node($o)->comment()
						|| ! scalar(
							grep {$_->inkey() eq $inkey &&
								$_->outkey() eq $outkey}
							@{$alignment->node($outkey, $o)}))) {
					push @$outnodes, $o
						if (! $outgraph->node($o)->comment()
							&& ! @{$alignment->node($outkey, $o)});
					 ++$o;
				}

				# Find next in-edge
				while ($i <= $i2 && ($ingraph->node($i)->comment()
						|| ! scalar(
							grep {$_->inkey() eq $inkey &&
								$_->outkey() eq $outkey}
							@{$alignment->node($inkey, $i)}))) {
					push @$innodes, $i
						if (! $ingraph->node($i)->comment()
							&& ! @{$alignment->node($inkey, $i)});
					 ++$i;
				}

				# Process resulting in- and out-edge
				my $outedges = $alignment->node($outkey, $o);
				my $inedges = $alignment->node($inkey, $i);
				if ($o <= $o2 && $i <= $i2) {
					if (scalar(@{$alignment->node($outkey, $o)}) == 1
							&& scalar(@{$alignment->node($inkey, $i)}) == 1
							&& $outedges->[0] eq $inedges->[0]) {
						# Edges are identical, hence parallel: store sequence
						push @$sequences, [$outnodes, $innodes]
							if (! $broken && (@$outnodes || @$innodes));

						# Store edge as previous edge, and go to next edge
						$innodes = [];
						$outnodes = [];
						$last = $outedges->[0];
						$broken = 0;
						$o = 1 + max($o,
							@{$outedges->[0]->outArray()});
						$i = 1 + max($i,
							@{$outedges->[0]->inArray()});
					} else {
						# Edges are non-parallel: find max $o and $i on edges
						$broken = 1;
						my ($o0, $i0) = ($o, $i);
						$innodes = [];
						$outnodes = [];

						# Find next $o
						$o = max($o, 
							@{$outedges->[0]->outArray()},
							@{$inedges->[0]->outArray()});

						# Find next $i
						$i = max($i, 
							@{$outedges->[0]->inArray()},
							@{$inedges->[0]->inArray()});

						# Increment $o and $i if equal to $o0,$i0
						if ($o == $o0 && $i == $i0) {
							++$o;
							++$i;
						}
					}
				}
			}

			# Add m-n sequences as edges
			foreach my $sequence (@$sequences) {
				my $nout = scalar(@{$sequence->[0]});
				my $nin = scalar(@{$sequence->[1]});
				if ($nin == $nout && $nin > 0) {
					# create n edges 1-1
					for (my $i = 0; $i < $nin; ++$i) {
						my $aedge = AEdge->new();
						$aedge->outkey($outkey);
						$aedge->out([$sequence->[0]->[$i]]);
						$aedge->inkey($inkey);
						$aedge->in([$sequence->[1]->[$i]]);
						$aedge->type(' ! ');
						$aedge->creator(-100);
						$aedge->alex($alex_parallel);
						$remaining->{$aedge} = $aedge;
					}
				} elsif ($nin > 0 && $nout > 0 && ($nin == 1 || $nout == 1)) {
					# create one edge 1-n or m-1
					# my $aedge = AEdge->new();
					# $aedge->outkey($outkey);
					# $aedge->out($sequence->[0]);
					# $aedge->inkey($inkey);
					# $aedge->in($sequence->[1]);
					# $aedge->type(' ! ');
					# $aedge->creator(-100);
					# $aedge->alex($alex_parallel);
					# $remaining->{$aedge} = $aedge;
					} else {
					# create no edge
				}
			}

			# Increment phase counter
			$phase = 1;
		}


		# Index edges wrt nodes
		my $hash = {};
		foreach my $edge (values(%$remaining)) {
			# Out-nodes
			foreach my $node (@{$edge->outArray()}) {
				if (! exists $hash->{"o$node"}) {
					$hash->{"o$node"} = [];
				}
				push @{$hash->{"o$node"}}, $edge;
			}

			# In-nodes
			foreach my $node (@{$edge->inArray()}) {
				if (! exists $hash->{"i$node"}) {
					$hash->{"i$node"} = [];
				}
				push @{$hash->{"i$node"}}, $edge;
			}
		}

		# Find lowest-cost edge with:
		#	(a) minimal maximal number of overlaps on any node on edge;
		#	(b) minimal minimal number of overlaps on any node on edge;
		#   (c) minimal number of resulting crossing edges in graph
		#	(d) minimal number of preceding unaligned nodes
		#	(e) highest probability in lexicon

		my $minmaxoverlaps = 1e30;
		my $minminoverlaps = 1e30;
		my $mincross = 1e30;
		my $mindist = 1e30;
		my $minprob = 1e30;
		my $minedge;
		my $crossings = {};
		foreach my $edge (values(%$remaining)) {
			# Find minimal and maximal number of overlaps at edge
			my ($minoverlaps, $maxoverlaps) = 
				minmax(
					(map {$#{$hash->{"i" . $_} || []}} @{$edge->inArray()}),
					(map {$#{$hash->{"o" . $_} || []}} @{$edge->outArray()}));

			# Find number of crossings
			$crossings->{$edge} = scalar(@{$alignment->new_crossings($edge)})
					if (! exists $crossings->{$edge});
			my $cross = $crossings->{$edge};

			# Find difference in number of preceding gaps
			my $odist = 0;
			my $opos = min(@{$edge->outArray()});
			foreach my $node (@$unaligned_out) {
				++$odist if ($node < $opos 
					&& !  @{$alignment->node($outkey, $node)});
			}
			my $idist = 0;
			my $ipos = min(@{$edge->inArray()});
			foreach my $node (@$unaligned_in) {
				++$idist if ($node < $ipos 
					&& !  @{$alignment->node($inkey, $node)});
			}
			my $dist = $odist + $idist;

			# Find probability of edge
			my $prob = $edge->alex()->pos();

			#print "maxoverlaps=$maxoverlaps minoverlaps=$minoverlaps cross=$cross dist=$dist " .  $edge->string() . "\n";
			if (0 > (($maxoverlaps <=> $minmaxoverlaps)
					|| ($minoverlaps <=> $minminoverlaps)
					|| ($cross <=> $mincross)
					|| ($dist <=> $mindist)
					|| ($minprob <=> $prob))) {
				if ($cross > $maxcross) {
					# print "blocked by maxcross: " 
					#	.  $edge->string() . "\n";
				} else {
					$minminoverlaps = $minoverlaps;
					$minmaxoverlaps = $maxoverlaps;
					$mincross = $cross;
					$mindist = $dist;
					$minprob = $prob;
					$minedge = $edge;
					# print "select " . $edge->string() . " as currently best\n";
				}
			}
		}

		# Add edge to graph and remove all incompatible edges
		if ($minedge) {
			# print "autoalign: maxoverlaps=$minmaxoverlaps minoverlaps=$minminoverlaps cross=$mincross dist=$mindist " . $minedge->string() . " " . $minedge->alex()->string() . "\n";

			# Add edge
			$alignment->add_edge($minedge);
			foreach my $node (
					(map {"o$_"} @{$minedge->outArray()}),
					(map {"i$_"} @{$minedge->inArray()})) {
				# Delete all edges at node from remaining
				foreach my $e (@{$hash->{$node}}) { 
					delete $remaining->{$e} if (exists $remaining->{$e});
				}
			}
		} else {
			# print "UNEXPECTED TERMINATION!\n";
			last();
		}
	}
}


sub minmax {
	my $min = shift;
	my $max = $min;
	while (@_) {
		$min = $_[0] if ($min > $_[0]);
		$max = $_[0] if ($max < $_[0]);
		shift();
	}
	return ($min, $max);
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/autoevaluate.pl
## ------------------------------------------------------------

sub autoevaluate {
	my $self = shift;
	my $alignment = shift;
	my $copy = shift;

	# Parameters
	my $outkey = "a";
	my $inkey = "b";
	my $outgraph = $alignment->graph($outkey);
	my $ingraph = $alignment->graph($inkey);
	my $accepted = {};
	my $recalled = {};
	my $covered = {};

	# Create empty copy of alignment
	if (! defined($copy)) {
		$copy = DTAG::Alignment->new();
		$copy->var('graphs', $alignment->graphs());
	}
	$copy->var('alexicon', $self);
	print $copy->write_atag();

	# Order all edges in graph in components
	my $components = {};
	my ($min, $max) = ({}, {});
	foreach my $edge (@{$alignment->edges()}) {
		if (! exists $components->{$edge}) {
			# Find component for edge and add it to hash
			my $component = $alignment->component($edge);

			$min->{$component} = {};
			$max->{$component} = {};
			foreach my $e (@$component) {
				$components->{$e} = $component 
					if (! exists $components->{$e});

				# Find min-max for outkey
				$min->{$component}{$e->outkey()} 
					= min(@{$e->outArray()},
						$min->{$component}{$e->outkey()});
				$max->{$component}{$e->outkey()} 
					= max(@{$e->outArray()},
						$max->{$component}{$e->outkey()});

				# Find min-max for inkey
				$min->{$component}{$e->inkey()} 
					= min(@{$e->inArray()},
						$min->{$component}{$e->inkey()});
				$max->{$component}{$e->inkey()} 
					= max(@{$e->inArray()},
						$max->{$component}{$e->inkey()});
			}
		}
	}

	# Assign min to deletion edges
	foreach my $edge (@{$alignment->edges()}) {
		if ($edge->outkey() eq $edge->inkey()) {
			my $component = $components->{$edge};
			if ($edge->outkey() eq $outkey) {
				# Find min{in} for out-out edge
				$min->{$component}{$inkey} = 1e30;
				for (my $o = min(@{$edge->outArray()}) ; $o >= 0; --$o) {
					my $oedges = $alignment->node($outkey, $o);
					if (@$oedges) {
						$min->{$component}{$inkey} =
							min($min->{$component}{$inkey},
								map {
									($_->inkey() eq $inkey)
										? @{$_->inArray()} : 1e30}
								@$oedges);
						last() if ($min->{$component}{$inkey} < 1e30);
					}
				}
				$min->{$component}{$inkey} = 0
					if ($min->{$component}{$inkey} == 1e30);
			} elsif ($edge->inkey() eq $inkey) {
				# Find min{out} for in-in edge
				$min->{$component}{$outkey} = 1e30;
				for (my $i = min(@{$edge->inArray()}) ; $i >= 0; --$i) {
					my $iedges = $alignment->node($inkey, $i);
					if (@$iedges) {
						$min->{$component}{$outkey} =
							min($min->{$component}{$outkey},
								map {
									($_->outkey() eq $outkey)
										? @{$_->outArray()} : 1e30}
								@$iedges);
						last() if ($min->{$component}{$outkey} < 1e30);
					}
				}
				$min->{$component}{$outkey} = 0
					if ($min->{$component}{$outkey} == 1e30);
			} else {
				# A weird edge that is neither inkey nor outkey
				$min->{$component}{$outkey} = 0;
				$min->{$component}{$inkey} = 0;
			}
		}
	}
	# Sort components
	my $C = {};
	map {$C->{$_} = $_} values(%$components);
	my $sorted_components = [
		sort {
			($min->{$a}{$outkey} <=> $min->{$b}{$outkey}) 
				|| ($min->{$a}{$inkey} <=> $min->{$b}{$inkey})
		} values(%$C)
	];

	# Process components and edges in order
	foreach my $component (@$sorted_components) {
		foreach my $edge (@$component) {
			# print $edge->string() . "\n";

			# Auto-offset and autoalign copy
			$copy->auto_offset();
			$self->autoalign($copy);

			# Look for edge in copy
			my $match;
			foreach my $e (@{$copy->node($edge->outkey(), 
					$edge->outArray()->[0])}) {
				# Change " ! " label to ""
				$e->type("") if ($e->type() eq " ! ");
				if ($e->string() eq $edge->string()) {
					# Print 
					print "ok: " . $e->string() . "\n";

					# Set match and change creator
					$match = $e;
					$e->creator(-1);

					# Set recalled and accepted hashes
					map {$recalled->{$e->outkey() . $_} = 1;
						$accepted->{$e->outkey() . $_} = 1;
						$covered->{$e->outkey() . $_} = 1} 
						@{$e->outArray()};
					map {$recalled->{$e->inkey() . $_} = 1;
						$accepted->{$e->inkey() . $_} = 1;
						$covered->{$e->inkey() . $_} = 1} 
						@{$e->inArray()};

					# Skip all other edges
					last();
				}
			}

			# Add edge manually if it wasn't created automatically
			if (! $match) {
				# Print 
				print "add: " . $edge->string() . "\n";

				# Set recalled hashes
				map {$covered->{$edge->outkey() . $_} = 1;
					$recalled->{$edge->outkey() . $_} = 1
						if (@{$copy->node($edge->outkey(), $_)})} 
					@{$edge->outArray()};
				map {$covered->{$edge->inkey() . $_} = 1;
					$recalled->{$edge->inkey() . $_} = 1
						if (@{$copy->node($edge->inkey(), $_)})} 
					@{$edge->inArray()};

				# Store edge
				$copy->add_edge($edge);
				$self->train_edge($copy, $edge);
			}
		}
	}

	# Print precision and recall
	my $ncovered = scalar(keys(%$covered));
	my $nrecalled = scalar(keys(%$recalled));
	my $naccepted = scalar(keys(%$accepted));

	print "nodes=$ncovered analyzed=$nrecalled correct=$naccepted\n";
	printf "recall=%.1f%% precision=%.1f%% F-score=%.1f%%\n", 
		(100 * $naccepted / $ncovered),
		(100 * $naccepted / $nrecalled),
		(200 * $naccepted / 
			($nrecalled + $ncovered));

	# Reset autoaligner
	$copy->var('autoalign', 0);
	$copy->var('offsets', {});
	$copy->var('imax', {});
	$copy->var('imin', {});

	# Return copy
	return $copy;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/clear.pl
## ------------------------------------------------------------

sub clear {
	my $self = shift;

	# Initialize variables
	$self->alex([]);
	$self->out({});
	$self->in({});
	$self->fout({});
	$self->fin({});
	$self->lang1('');
	$self->lang2('');
	$self->var('gaps', {});
	$self->var('regexps', {});

	# Set empty sublexicon, if no existing sublexicon array
	$self->sublexicons([]) if (! $self->sublexicons());

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/file.pl
## ------------------------------------------------------------

=item $alignment->file($file) = $file

Get/set file associated with alignment.

=cut

sub file {
	my $self = shift;
	return $self->var('_file', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/fin.pl
## ------------------------------------------------------------

sub fin {
	my $self = shift;
	return $self->var('fin', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/fout.pl
## ------------------------------------------------------------

sub fout {
	my $self = shift;
	return $self->var('fout', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/gaps.pl
## ------------------------------------------------------------

sub gaps {
	my $self = shift;
	my $type = shift;
	$type = "" if (! defined($type));

	my $gaps = $self->var('gaps');

	return (exists $gaps->{$type})
		? $gaps->{$type} 
		: ($gaps->{$type} = []);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/in.pl
## ------------------------------------------------------------

sub in {
	my $self = shift;
	return $self->var('in', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/insert.pl
## ------------------------------------------------------------

sub insert {
	my $self = shift;
	my $alex = shift;

	# Insert alex into lexicon
	my $id = $self->new_alex_id();
	my $alexlist = $self->alex();
	$alexlist->[$id] = $alex;

	# Insert alex into in and out pattern hash tables
	$self->insert_pattern($self->in(), $alex->in(), $id, $self->fin());
	$self->insert_pattern($self->out(), $alex->out(), $id, $self->fout());

	# Return
	return $self;
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/insert_key.pl
## ------------------------------------------------------------

sub insert_key {
	my $self = shift;
	my $hash = shift;
	my $key = lc(shift);
	my $id = shift;
	my $fhash = shift;

	# Create array for key, if necessary
	my $idlist = (exists $hash->{$key}) ? $hash->{$key} : [];

	# Add id to array, sort it, and use it as new idlist
	if (! exists $fhash->{$key}) {
		# Create entry
		$hash->{$key} = [ sort($id, @$idlist) ];

		# Check whether entry should be added to list of function words
		$fhash->{$key} = 1 
			if (scalar(@{$hash->{$key}}) > $FUNCTIONWORD_MAXCOUNT);
	}
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/insert_pattern.pl
## ------------------------------------------------------------

sub insert_pattern {
	my $self = shift;
	my $hash = shift;
	my $pattern = shift;
	my $id = shift;
	my $fhash = shift;

	# Insert each defined key in hash tables
	foreach my $key (@$pattern) {
		if (! defined($key)) {
			# Do nothing
		} elsif ($key =~ /^\/.*\/$/) {
			# Insert regular expression
			$self->insert_regexp($hash, $key, $id);
		} else {
			# Insert word
			$self->insert_key($hash, $key, $id, $fhash);
		}
	}
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/insert_regexp.pl
## ------------------------------------------------------------

sub insert_regexp {
	my $self = shift;
	my $hash = shift;
	my $key = shift;
	my $id = shift;

	# Find regexp hash
	if (! exists $hash->{'__regexps__'}) {
		$hash->{'__regexps__'} = {};
	}
	my $hregexps = $hash->{'__regexps__'};
	my $idlist = (exists $hregexps->{$key}) ? $hregexps->{$key} : [];

	# Compile regexp
	my $regexps = $self->var('regexps');
	if (! exists $regexps->{$key}) {
		my $sub = eval("sub { my \$s = shift; return (\$s =~ $key) ? 1 : 0 }");
		$self->{'regexps'}{$key} = $sub;
	}

	# Insert id into list of ids
	$hash->{'__regexps__'}{$key} = [ sort($id, @$idlist) ];
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/intsct.pl
## ------------------------------------------------------------

# Intersect two ordered lists
sub intsct {
	my $list1 = shift;
	my $list2 = shift;

	$list1 = [ sort {$a <=> $b} @$list1 ];
	$list2 = [ sort {$a <=> $b} @$list2 ];

	# Initialize variables
	my $intsct = [];
	my $i = 0;
	my $j = 0;
	$| = 1;
	
	# Intersect lists
	while ($i < scalar(@$list1) && $j < scalar(@$list2)) {
		if ($list1->[$i] == $list2->[$j]) {
			push @$intsct, $list1->[$i];
			++$i;
			++$j;
		} elsif ($list1->[$i] < $list2->[$j]) {
			$i = find_first_ge($list1, $list2->[$j], $i);
		} elsif ($list1->[$i] > $list2->[$j]) {
			$j = find_first_ge($list2, $list1->[$i], $j);
		}
	}

	# Return intersection
	return $intsct;
}

sub find_first_ge {
	my $list = shift;
	my $value = shift;
	my $i1 = shift;
	my $i2 = scalar(@$list) - 1; 

	# Search for first index where $list[$i] >= $value
	while ($list->[$i1] < $value && $i1 != $i2) {
		my $mid = int(($i1 + $i2 + 1) / 2);
		if ($list->[$mid] < $value) {
			$i1 = $mid;
		} elsif ($mid == $i1 + 1 && $list->[$i1] < $value) {
			$i1 = $i2 = $mid;
		} else {
			$i2 = $mid;
		}
	}

	# Return index
	return $list->[$i1] < $value ? $i1 + 1 : $i1;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/lang1.pl
## ------------------------------------------------------------

sub lang1 {
	my $self = shift;
	return $self->var('lang1', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/lang2.pl
## ------------------------------------------------------------

sub lang2 {
	my $self = shift;
	return $self->var('lang2', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/load_alex.pl
## ------------------------------------------------------------

sub load_alex {
	my $self = shift;
	my $file = shift;

	# Open file
	open("ALEX", "< $file")
		|| return DTAG::Interpreter::error("cannot open alex-file for reading: $file");

	# Process lexicon file
	my $count = 0;
	while (my $line = <ALEX>) {
		if ($line =~ /^<DTAGalex lang1="([^"]*)" lang2="([^"]*)">$/) {
			# Specify language
			$self->lang1($1);
			$self->lang2($2);
		} elsif ($line =~ /^<sublex file="([^"]*)"\/>$/) {
			# Load sublexicon
			my $sublexicon = ALexicon->new()->load_alex($1);
			push @{$self->sublexicons()}, $sublexicon;
		} elsif ($line =~ /^<alex pos="([^"]*)" neg="([^"]*)" out="([^"]*)" type="([^"]*)" in="([^"]*)"\/>$/) {
			# Create new ALex entry
			$self->add_alex(str2pattern($3), $4, str2pattern($5), $1, $2);
		} elsif ($line =~ /^<gap pos="([0-9]*)" type="([^"]*)" width="([0-9]*)"\/>/) {
			# Record number of gaps
			my $gaps = $self->gaps($2);
			$gaps->[$3] = ($gaps->[$3] || 0) + $1;
			$self->var('total_gaps', 
				($self->var('total_gaps') || 0) + $1);
		} elsif ($line =~ /^<\/DTAGalex>$/ || $line =~ /^<!--.*-->$/) {
			# Do nothing
		} else {
			# Unknown line in .alex file!
			print "ALexicon->load_alex: unknown lexicon line $line in file $file\n";;
		}

		# Print dot for every 1000th line
		++$count;
		$| = 1;
		print "." if ($count % 1000 == 0);
	}
	print "loaded\n";

	# Close file
	close("ALEX");

	# Return alexicon
	return $self;
}

sub str2pattern {
	my $string = shift;
	my $pattern = [ split(/ /, $string) ];
	for (my $i = 0; $i < $#$pattern; ++$i) {
		$pattern->[$i] = undef
			if ($pattern->[$i] eq "*");
	}
	return $pattern;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/lookup_global.pl
## ------------------------------------------------------------

sub lookup {
	my $self = shift;
	my $out = shift;
	my $type = shift;
	my $in = shift;

	# Return local entry, if there is one
	my $alex = $self->lookup_local($out, $type, $in);
	return $alex if ($alex);

	# Return first entry in sublexicon, if there is one
	foreach my $sub (@{$self->sublexicons()}) {
		$alex = $sub->lookup($out, $type, $in);
		return $alex if ($alex);
	}

	# No matching entry found
	return undef;
}




## ------------------------------------------------------------
##  auto-inserted from: ALexicon/lookup_hash.pl
## ------------------------------------------------------------

sub lookup_hash {
	my $self = shift;
	my $key = lc(shift);
	my $hash = shift;
	my $fhash = shift;

	# Lookup edge in ordinary lexicon
	my $alexlist = $self->alex();
	my $alexs = [];
	if (exists $hash->{$key} && ! exists $fhash->{$key}) {
		push @$alexs, map {$alexlist->[$_]->clone()} @{$hash->{$key}};
	}

	# Lookup edge among regular expressions
	my $regexp2sub = $self->var('regexps');
	foreach my $regexp (keys %{$hash->{'__regexps__'}}) {
		my $sub = $regexp2sub->{$regexp};
		push @$alexs,
				(map {$alexlist->[$_]->clone()} 
					@{$hash->{'__regexps__'}{$regexp}})
			if (&$sub($key));
	}
	
	# Return empty list
	return $alexs;
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/lookup_in.pl
## ------------------------------------------------------------

sub lookup_in {
	my $self = shift;
	my $in = shift;

	# Lookup word locally
	my $alexes = $self->lookup_hash($in, $self->in(), $self->fin());
	
	# Initialize strings array to ensure words are only seen once
	my $hash = {};
	map {$hash->{$_->string()} = $_}  @$alexes;

	# Lookup word in sublexicons
	foreach my $sublex (@{$self->sublexicons()}) {
		my $alexes_sub = $sublex->lookup_in($in);
		foreach my $alexnew (@$alexes_sub) {
			my $alexold = $hash->{$alexnew->string()};
			if ($alexold) {
				# Update entry
				$alexold->pos($alexold->pos() + $alexnew->pos());
				$alexold->neg($alexold->neg() + $alexnew->neg());
			} else {
				# Create new entry
				$hash->{$alexnew->string()} = $alexnew;
			}
		}
	}

	# Return
	return [ values(%$hash) ];
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/lookup_local.pl
## ------------------------------------------------------------

sub lookup_local {
	my $self = shift;
	my $out = shift;
	my $type = shift;
	my $in = shift;

	# Find out and in candidates for match
	my $outcand = $self->match_keys($self->out(), $out);
	my $incand = $self->match_keys($self->in(), $in);

	# Intersect the two lists
	my $intsct = intsct($incand, $outcand);

	# Go through all alex on list in order to find match
	my $alexlist = $self->alex();
	foreach my $alex (@$intsct) {
		my $alexobj = $alexlist->[$alex];
		if ($alexobj->match($out, $type, $in)) {
			return $alexobj;
		}
	}

	# No match found
	return undef;
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/lookup_out.pl
## ------------------------------------------------------------

sub lookup_out {
	my $self = shift;
	my $out = shift;
	my $hash = shift || {};


	# Lookup word locally
	my $alexes = $self->lookup_hash($out, $self->out(), $self->fout());
	
	# Initialize strings array to ensure words are only seen once
	map {$hash->{$_->string()} = $_}  @$alexes;

	# Lookup word in sublexicons
	foreach my $sublex (@{$self->sublexicons()}) {
		my $alexes_sub = $sublex->lookup_out($out);
		foreach my $alexnew (@$alexes_sub) {
			my $alexold = $hash->{$alexnew->string()};
			if ($alexold) {
				# Update entry
				$alexold->pos($alexold->pos() + $alexnew->pos());
				$alexold->neg($alexold->neg() + $alexnew->neg());
			} else {
				# Create new entry
				$hash->{$alexnew->string()} = $alexnew;
			}
		}
	}

	# Return
	return [ values(%$hash) ];
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/lookup_words.pl
## ------------------------------------------------------------

sub lookup_words {
	my $self = shift;
	my $outwords = shift;
	my $inwords = shift;

	# print "lookup_words: " . DTAG::Interpreter::dumper($inwords, $outwords) . "\n";

	# Save hash
	my $hash = { };

	# Lookup in-words
	foreach my $inword (@$inwords) {
		foreach my $alex (@{$self->lookup_in($inword)}) {
			$hash->{$alex->string()} = $alex;
		}
	}

	# Lookup out-words
	foreach my $outword (@$outwords) {
		foreach my $alex (@{$self->lookup_out($outword)}) {
			$hash->{$alex->string()} = $alex;
		}
	}

	# Return all alexes
	return [ values(%$hash) ];
}
	

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/match_keys.pl
## ------------------------------------------------------------

# Find candidates for hash entries that match all keys 
sub match_keys {
	my $self = shift;
	my $hash = shift;
	my $keys = shift;

	# Check whether all keys exist
	my $defined = shift;
	foreach my $uckey (@$keys) {
		my $key = lc($uckey);
		if (defined($key)) {
			return [] if (! exists $hash->{$key});
			push @$defined, $key;
		}
	}

	# Sort keys according to number of matches
	my @sorted = sort {
		scalar(@{$hash->{$a}}) <=>
			scalar(@{$hash->{$b}})
	} @$defined;

	# Intersect all lists
	my $intsct = $hash->{$sorted[0]};
	shift(@sorted);
	foreach my $key (@sorted) {
		$intsct = intsct($intsct, $hash->{$key});
	}

	# Return intersection
	return $intsct;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/match_pattern.pl
## ------------------------------------------------------------

sub match_pattern {
	my $self = shift;
	my $graph = shift;
	my $nodes = shift;
	my $pattern = shift;
	my $prefix = shift || [];
	my $matches = shift || [];
	my $imin = shift || 0;
	my $imax = shift;
	$imax = defined($imax) ? min($imax, $#$nodes) : $#$nodes;

	#print "match_pattern: " . 
	#	DTAG::Interpreter::dumper(["nodes", $nodes, "pattern",
	#$pattern, "prefix", $prefix, "matches", $matches, "imin", $imin,
	#	"imax", $imax]) . "\n";

	# Succeed if pattern is empty
	if (! @$pattern) {
		push @$matches, $prefix;
		return $matches;
	}

	# Try each node as starting point
	for (my $i = $imin; $i <= $imax; ++$i) {
		# Test whether starting point matches
		my $node1 = $graph->node($nodes->[$i]);
		if ((lc($node1->input()) eq lc($pattern->[0]))
				|| ($pattern->[0] =~ /^\/.*\/$/ 
					&& &{$self->var('regexps')->{$pattern->[0]} ||
					$dummysub}($node1->input()))) {
			# Starting point matches
			if ($#$pattern == 0) {
				# Remaining pattern is empty
				push @$matches, [@$prefix, $nodes->[$i]];
			} elsif (defined($pattern->[1])) {
				# Next pattern is not a gap: check that next node is adjacent
				my $nextnode = $graph->next_noncomment_node($nodes->[$i] + 1);
				# print "pattern: next=$nextnode i=$i nodes[i]+1=" .
				#	($nodes->[$i] + 1) . 
				#	"nodes[i+1]=" . $nodes->[$i+1] . "\n";
				if ($i < $#$nodes && $nodes->[$i+1] == $nextnode) {
					$self->match_pattern($graph, $nodes, 
						[@$pattern[1..$#$pattern]],
						[@$prefix, $nodes->[$i]],
						$matches,
						$i + 1,
						$i + 1);
				}	
			} else {
				# Next pattern is a gap: skip any number of words
				$self->match_pattern($graph, $nodes, 
					[@$pattern[2..$#$pattern]],
					[@$prefix, $nodes->[$i]],
					$matches,
					$i + 1,
					$#$nodes);
			}
		}
	}

	# Return matches
	return $matches;
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/minmax.pl
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
##  auto-inserted from: ALexicon/mtime.pl
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
##  auto-inserted from: ALexicon/new.pl
## ------------------------------------------------------------

=item ADictionary->new() = $adict

Create new ADictionary object.

=cut

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self: 
	my $self = { };

	# Specify class for new object
	bless ($self, $class);
	$self->clear();

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/new_alex_id.pl
## ------------------------------------------------------------

sub new_alex_id {
	my $self = shift;
	my $old = $self->var('alex_id') || 0;
	$self->var('alex_id', $old + 1);
	return $old;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/new_sublexicon.pl
## ------------------------------------------------------------

sub new_sublexicon {
	my $self = shift;

	my $sublexicon = DTAG::ALexicon->new();
	$sublexicon->var('regexps', $self->var('regexps'));
	push @{$self->sublexicons()}, $sublexicon;
	return $sublexicon;
}
	

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/nodes2pattern.pl
## ------------------------------------------------------------

sub nodes2pattern {
	my $self = shift;
	my $alignment = shift;
	my $key = shift;
	my $nodes = shift;

	# Sort nodes
	$nodes = [sort(@$nodes)];

	# Find graph
	my $graph = $alignment->graph($key);

	# Process nodes
	my $pattern = [];
	my $gaps = [];
	my $last = $nodes->[0];
	my $gap = 0;
	my $nodeobj;
	foreach my $node (@$nodes) {
		# Look for gaps
		for (my $i = $last + 1; $i < $node ; ++ $i) {
			$nodeobj = $graph->node($node);
			++$gap if ($nodeobj && ! $nodeobj->comment());
		}

		# Insert node and dummy
		$nodeobj = $graph->node($node);
		if ($nodeobj) {
			# Insert dummy after gap 
			if ($gap) {
				push @$pattern, undef;
				push @$gaps, $gap;
			}

			# Push node input onto pattern
			push @$pattern, ($nodeobj->input() || "");
			$gap = 0;
			$last = $node;
		}
	}

	# Return pattern and gap sizes
	return ($pattern, $gaps);
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ok.pl
## ------------------------------------------------------------

sub ok {
	my $self = shift;
	my $alignment = shift;
	
	# Find stored boundaries for last autoalign
	my $boundaries = $alignment->var('autoalign');
	if (! $boundaries) {
		DTAG::Interpreter::error("no automatically created alignment edges");
		return 0;
	}
	my ($outkey, $o1, $o2, $inkey, $i1, $i2) = @$boundaries;

	# Modify creator in autoaligned edges
	foreach my $edge (@{$alignment->edges()}) {
		# Skip if edge is outside current boundaries
		next() if (! $alignment->edge_in_autowindow($edge));

		# Change label from " ! " to ""
		$edge->type("") if ($edge->type() eq " ! ");

		# Change creator
		$edge->creator(-1) if ($edge->creator() <= -100);
	}

	# Retrain lexicon
	$self->untrain();
	$self->train($alignment);

	# Return success
	return 1;
}




## ------------------------------------------------------------
##  auto-inserted from: ALexicon/out.pl
## ------------------------------------------------------------

sub out {
	my $self = shift;
	return $self->var('out', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/sublexicons.pl
## ------------------------------------------------------------

sub sublexicons {
	my $self = shift;
	return $self->var('sublexicons', @_);
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/train.pl
## ------------------------------------------------------------

sub train {
	my $self = shift;
	my $alignment = shift;
	my $weight = shift || 1;

	# Read off all edges from alignment file
	foreach my $e (@{$alignment->edges()}) {
		# Train with edge
		$self->train_edge($alignment, $e, $weight);
	}

	# Return
	return $self;
}
	


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/train_edge.pl
## ------------------------------------------------------------

sub train_edge {
	my $self = shift;
	my $alignment = shift;
	my $edge = shift;
	my $weight = shift || 1;

	# Compute in and out pattern, and count number of gaps
	my ($outpattern, $outgaps) = 
		$self->nodes2pattern($alignment, $edge->outkey(), $edge->outArray()); 
	my ($inpattern, $ingaps) = 
		$self->nodes2pattern($alignment, $edge->inkey(), $edge->inArray()); 

	# Store alex entry and observed number of gaps
	$self->add_alex($outpattern, $edge->type(), $inpattern, $weight);
	$self->add_gaps('out', $outgaps);
	$self->add_gaps('in', $ingaps);
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/untrain.pl
## ------------------------------------------------------------

sub untrain {
	my $self = shift;

	# Initialize variables
	$self->alex([]);
	$self->out({});
	$self->in({});
	$self->var('gaps', {});
	$self->var('regexps', {});

	# Set empty sublexicon, if no existing sublexicon array
	$self->sublexicons([]) if (! $self->sublexicons());

	# Return
	return $self;
}	

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/var.pl
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
##  auto-inserted from: ALexicon/window.pl
## ------------------------------------------------------------

sub window {
	my $self = shift;
	return $self->var('window', @_) || 20;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/write_alex.pl
## ------------------------------------------------------------

sub write_alex {
	my $self = shift;
	my $sublexicons = shift;
	my $noheader = shift;

	my $s;
	
	# Write header
	if (! $noheader) {
		# Header
		$s = '<DTAGalex lang1="' . $self->lang1() 
			. '" lang2="' .  $self->lang2() . "\">\n";

		# Write sublexicons
		if ($sublexicons) {
			foreach my $sublex (@{$self->sublexicons()}) {
				$s .= "<sublex file=\"" . 
					($sublex->file() || "") . "\"/>\n";
			}
		}
	}

	# Write lexical entries
	my $alex_list = $self->alex();
	for (my $id = 0; $id < scalar(@$alex_list); ++$id) {
		my $alex = $alex_list->[$id];
		if ($alex) {
			$s .= "<alex pos=\"" . $alex->pos()
				. "\" neg=\"" . $alex->neg()
				. "\" out=\"" . seq2str($alex->out())
				. "\" type=\"" . $alex->type()
				. "\" in=\"" . seq2str($alex->in())
				. "\"/>\n";
		}
	}

	# Write gap probabilities
	my $gaps = $self->{'gaps'};
	foreach my $gap (sort(keys(%$gaps))) {
		my $gaplist = $self->gaps($gap);
		for (my $g = 1; $g < scalar(@$gaplist); ++$g) {
			my $pos = $gaplist->[$g] || 0;
			$s .= "<gap pos=\"$pos\" type=\"$gap\" width=\"$g\"/>\n"
				if ($pos > 0);
		}
	}

	# Write entries from sublexicons
	if (! $sublexicons) {
		foreach my $sublexicon (@{$self->sublexicons()}) {
			$s .= "<!--sublexicon: \"" . ($sublexicon->file() || "") .  "\"-->\n";
			$s .= $sublexicon->write_alex(0, 1);
		}
	}

	# Write end tag
	if (! $noheader) {
		$s .= "</DTAGalex>\n";
	}

	# Return string
	return $s;
}

sub seq2str {
	my $list = shift;
	my $str = join(" ",
		map {defined($_) ? $_ : "*"} @$list);
	
	# Replace " with &quot;
	$str =~ s/"/&quot;/g;

	# Return
	return $str;
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
##  auto-inserted from: ALexicon/ALex/HEADER.pl
## ------------------------------------------------------------

# --------------------------------------------------

=head1 ALex

=head2 NAME

ALex - entry in alignment lexicon

=head2 DESCRIPTION

ALex - entry in alignment lexicon

=head2 METHODS

=over 4

=cut

# --------------------------------------------------

package ALex;
use strict;




## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/clone.pl
## ------------------------------------------------------------

sub clone {
	my $self = shift;
	my $clone = ALex->new();

	# Copy self to clone
	for (my $i = 0; $i < scalar(@$self); ++$i) {
		$clone->[$i] = $self->[$i];
	}

	# Return clone
	return $clone;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/eq.pl
## ------------------------------------------------------------

sub eq {
	my $self = shift;
	my $alex = shift;
	return $self->match($alex->out(), $alex->type(), $alex->in());
}


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/id.pl
## ------------------------------------------------------------

sub id {
	my $self = shift;
	$self->[5] = shift if (@_);
	return $self->[5] || [];
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/in.pl
## ------------------------------------------------------------

sub in {
	my $self = shift;
	$self->[1] = shift if (@_);
	return $self->[1] || [];
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/incneg.pl
## ------------------------------------------------------------

sub incneg {
	my $self = shift;
	$self->[4] += shift if (@_);
	return $self->[4] || 0;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/incpos.pl
## ------------------------------------------------------------

sub incpos {
	my $self = shift;
	$self->[3] += shift if (@_);
	return $self->[3] || 0;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/match.pl
## ------------------------------------------------------------

sub match {
	my $self = shift;
	my $out = shift;
	my $type = shift;
	my $in = shift;

	# Check type
	return 0 
		if ($self->type() ne $type
			|| (! list_eq($self->in(), $in)) 
			|| (! list_eq($self->out(), $out))
		);
	
	# Return match
	return 1;
}

sub list_eq {
	my $list1 = shift;
	my $list2 = shift;

	return 0 if (scalar(@$list1) ne scalar(@$list2));

	for (my $i = 0; $i < scalar(@$list1); ++$i) {
		return 0 if (
			(defined($list1->[$i]) ? $list1->[$i] : "__UNDEFINED__")
			ne 
			(defined($list2->[$i]) ? $list2->[$i] : "__UNDEFINED__"))
	}

	# All elements matched
	return 1;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/neg.pl
## ------------------------------------------------------------

sub neg {
	my $self = shift;
	$self->[4] = shift if (@_);
	return $self->[4] || 0;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/new.pl
## ------------------------------------------------------------

=item ADictionary->new() = $adict

Create new ADictionary object.

=cut

# out=0 in=1 type=2 pos=3 neg=4 id=5 allpos=6 allneg=7

sub new {
	# Create new object and find its class
	my $proto = shift;
	my $class = ref($proto) || $proto;

	# Create self: 
	my $self = [ ];		

	# Specify class for new object
	bless ($self, $class);

	# Return
	return $self;
}	


## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/out.pl
## ------------------------------------------------------------

sub out {
	my $self = shift;
	$self->[0] = shift if (@_);
	return $self->[0] || [];
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/pos.pl
## ------------------------------------------------------------

sub pos {
	my $self = shift;
	$self->[3] = shift if (@_);
	return $self->[3] || 0;
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/string.pl
## ------------------------------------------------------------

sub string {
	my $self = shift;

	return join(" ", map {defined($_) ? $_ : "*"} @{$self->out()})
		. " =" . $self->type() . "=> "
		. join(" ", map {defined($_) ? $_ : "*"} @{$self->in()});
}

## ------------------------------------------------------------
##  auto-inserted from: ALexicon/ALex/type.pl
## ------------------------------------------------------------

sub type {
	my $self = shift;
	$self->[2] = shift if (@_);
	return $self->[2] || "";
}

1;

1;
