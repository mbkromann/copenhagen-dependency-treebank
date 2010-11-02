sub phonops {
	my $self = shift;
	$self->{'phonops'} = shift if (@_);
	return $self->{'phonops'};
}
