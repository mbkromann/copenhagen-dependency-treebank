sub goto_graph {
	my $self = shift;
	my $graph = shift;

	# Set new graph, and update viewer
	if ($graph >= 0 && $graph < scalar(@{$self->{'graphs'}})) {
		$self->{'graph'} = $graph;
		$self->cmd_return();
	}

	# Print changed graph
	print $self->graph()->print_graph($self->{'graph'}, $self->{'graph'} + 1)
		unless ($self->quiet());
	
	# Return
	return 1;
}
