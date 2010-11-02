sub plane {
	my $self = shift;
	$self->{'plane'} = shift if (@_);
	return $self->{'plane'};
}
