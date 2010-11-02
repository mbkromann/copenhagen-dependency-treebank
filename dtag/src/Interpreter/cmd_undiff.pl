sub cmd_undiff {
	my $self = shift;
	my $graph = shift;

	# Delete all edges marked as 'diff' in the graph
 	$graph->do_edges(
		sub {
			$_[1]->edge_del($_[0])
				if ($_[0]->var('diff'));
		},
		$graph);

	# Reset styles and layout for graph
	delete $graph->{'styles'};
	delete $graph->{'layout'};

	# Update graph
	$self->cmd_return($graph);

	# Return
	return 1;
}
