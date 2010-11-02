sub add_key {
	my $self = shift;
	my $key = shift;
	my $edge = shift;

	# Create node, if necessary
	my $nodes = $self->var('nodes');
	if (! exists $nodes->{$key}) {
		$nodes->{$key} = [];
	}

	# Add edge to node list
	push @{$nodes->{$key}}, $edge;
}

