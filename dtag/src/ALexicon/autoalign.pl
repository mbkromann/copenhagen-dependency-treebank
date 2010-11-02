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

