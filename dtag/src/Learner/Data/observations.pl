sub observations {
	my $self = shift;
	
	# Set observations
	$self->{'data'} = shift if (@_);

	# Get observations
	return $self->{'data'};
}
