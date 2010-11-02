sub cmd_graphs {
	my $self = shift;
	my $graph = shift;

	# Print graphs
	my $i = 1;
	my $current = $self->{'graph'} || 0;
	foreach my $g (@{$self->{'graphs'}}) {
		print $g->print_graph($current, $i);
		++$i;

		# Abort if requested
		last() if ($self->abort());
	}

	# Return
	return 1;
}

