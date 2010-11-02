sub mindata {
	my $self = shift;
	$self->{'mindata'} = shift if (@_);
	return $self->{'mindata'} || 5;
}
