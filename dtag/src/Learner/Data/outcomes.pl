sub outcomes {
	my $self = shift;
	
	# Set outcomes
	$self->{'outcomes'} = shift if (@_);

	# Get outcomes
	return $self->{'outcomes'};
}
