sub clear_edges {
	my $self = shift;
	
	# Delete all edges in graph
	for (my $i = 0; $i < $self->size(); ++$i) {
		# Delete all edges at node
		my $node = $self->node($i);
		my $edges = $node ? [ @{$node->in()}, @{$node->out()} ] : [];
		foreach my $edge (@$edges) {
			$self->edge_del($edge);
		}
	}
}
