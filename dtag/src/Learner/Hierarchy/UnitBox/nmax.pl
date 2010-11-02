sub nmax {
	my $self = shift;
	$self->{'nmax'} = shift if (@_);
	return $self->{'nmax'};
	}
