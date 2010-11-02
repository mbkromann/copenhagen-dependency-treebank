sub data {
	my $self = shift;
	$self->{'data'} = $self->{'rdata'} = shift if (@_);
	return $self->{'data'};
}

