# Specify the edges in the alignment directly (time-consuming)

sub set_edges {
	my $self = shift;
	my $edges = shift;

	# Erase all edges in the graph
	$self->erase_all();

	# Add all edges to the graph
	foreach my $edge (@$edges) {
		$self->add_edge($edge);
	}

	# Return
	return $self;
}

