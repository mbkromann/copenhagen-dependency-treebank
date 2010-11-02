=item $graph->edge_add($edge) = $edge

Add edge $edge to $graph.

=cut

sub edge_add {
	my $self = shift;
	my $edge = shift;
	my $unique = shift;

	# Find nodes
	my $nodein = $self->node($edge->in());
	my $nodeout = $self->node($edge->out());

	# Check legality of edge
	return DTAG::Interpreter::error("non-existent node: " . $edge->in()) 
		if (! defined($nodein));
	return DTAG::Interpreter::error("non-existent node: " . $edge->out()) 
		if (! defined($nodeout));
	
	# Check whether edge already exists
	my $exists = 0;
	foreach my $e (@{$nodein->in()}) {
		$exists = 1 if ($e->in() eq $edge->in()
			&& $e->out() eq $edge->out()
			&& $e->type() eq $edge->type());
	}

	# Add edge to nodes
	if (! ($unique && $exists)) {
		push @{$nodein->in()}, $edge;
		push @{$nodeout->out()}, $edge;
	}

	# Return
	return $edge;
}
