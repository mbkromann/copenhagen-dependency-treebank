sub data {
	my $self = shift;
	
	# Set outcomes
	$self->{'data'} = shift if (@_);

	# Get outcomes
	return $self->{'data'};
}
