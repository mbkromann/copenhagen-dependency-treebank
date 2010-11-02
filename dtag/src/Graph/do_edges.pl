=item $graph->do_edges($action, @args)

Call the procedure &$action($e, @args) for each edge $e in the graph. 

=cut

sub do_edges {
	my $self = shift;
	my $action = shift;

	# Process all edges
	my $n = $self->size();
	for (my $i = 0; $i < $n; ++$i) {
		# Find node and skip if comment
		my $node = $self->node($i);
		next() if $node->comment();

		foreach my $e (@{$node->in() || []}) {
			&$action($e, @{[@_]});
		}
	}

	# Return
	return 1;
}
