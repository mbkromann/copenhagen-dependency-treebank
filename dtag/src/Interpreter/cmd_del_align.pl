sub cmd_del_align {
	my $self = shift;
	my $graph = shift;
	my $ref = shift;

	# Check that $graph is an alignment
	if (ref($graph) ne "DTAG::Alignment") {
		error("current graph is not an alignment!");
		return 1;
	}

	# Delete edge with node
	$graph->del_node($ref);

	# Return
	return 1;
}
