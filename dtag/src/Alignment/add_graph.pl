sub add_graph {
	my $self = shift;
	my $key = shift;
	my $graph = shift;

	$self->{'graphs'}{$key} = $graph;
	$self->{'offsets'}{$key} = 0;
} 
