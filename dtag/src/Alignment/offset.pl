sub offset {
	my $self = shift;
	my $key = shift;

	# Set offset, if requested
	$self->{'offsets'}{$key} = min(shift() || 0,
		$self->graph($key)->size()-1) if (@_);

	# Get offset
	return $self->{'offsets'}{$key} || 0;
}
