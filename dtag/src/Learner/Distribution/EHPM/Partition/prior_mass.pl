sub prior_mass {
	my $self = shift;
	$self->{'prior_mass'} = shift if (@_);
	return $self->{'prior_mass'};
}
