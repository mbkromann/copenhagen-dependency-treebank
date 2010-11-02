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

