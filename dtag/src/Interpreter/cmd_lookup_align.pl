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

