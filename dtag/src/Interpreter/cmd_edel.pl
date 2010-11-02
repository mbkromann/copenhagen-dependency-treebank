sub cmd_edel {
	my $self = shift;
	my $graph = shift;
	my $noderel = shift;

	# Apply offset
	my $node = defined($noderel) ? $noderel + $graph->offset() : undef;

	# Check that $nodein is valid
	my $n  = $graph->node($node);
	return error("Non-existent node: " . ( $node || "?")) 
		if ((! defined($node)) || (! ref($n)));

	# Delete all in-edges at $n
	my @edges = @{$n->in()};
	foreach my $e (@edges) {
		# Delete edge if it matches description
		$graph->edge_del($e) 
	}

	# Mark graph as modified
    $graph->mtime(1);

	# Return
	return 1;
}

