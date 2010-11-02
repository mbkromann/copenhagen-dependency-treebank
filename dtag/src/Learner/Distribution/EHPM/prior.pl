sub prior {
	my $self = shift;
	$self->{'prior'} = shift if (@_);
	return $self->{'prior'};
}
