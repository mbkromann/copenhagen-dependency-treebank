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

