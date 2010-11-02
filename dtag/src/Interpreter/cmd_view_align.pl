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

