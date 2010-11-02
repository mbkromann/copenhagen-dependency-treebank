sub node_edges {
	my $self = shift;
	my $key = shift;
	my $node = shift;
	
	# Find all edges containing node
	my $edges = $self->edges();
	my $node_edges = [];
	for (my $e = 0; $e < scalar(@$edges); ++$e) {
		my $edge = $edges->[$e];
		push @$node_edges, $e
			if ($edge->contains($key, $node));
	}

	# Return edge list
	return $node_edges;
}
