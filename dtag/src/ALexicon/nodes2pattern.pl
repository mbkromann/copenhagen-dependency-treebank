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

