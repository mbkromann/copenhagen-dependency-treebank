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
