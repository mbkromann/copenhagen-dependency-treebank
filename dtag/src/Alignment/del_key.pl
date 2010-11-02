sub del_key {
	my $self = shift;
	my $key = shift;
	my $edge = shift;

	# Get array
	my $nodes = $self->var('nodes');
	my $array = [ 
		grep {$_ ne $edge} 
			@{$self->node($key)}
		];
	
	# Update nodes hash
	if (@$array) {
		$nodes->{$key} = $array;
	} else {
		delete $nodes->{$key};
	}
}
