sub smoothing {
	my $self = shift;
	$self->{'smoothing'} = shift if (@_);
	return $self->{'smoothing'};
}
