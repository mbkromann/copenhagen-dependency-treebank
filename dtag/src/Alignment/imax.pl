sub imax {
	my $self = shift;
	my $key = shift;
	$self->{'imax'}{$key} = shift if (@_);
	return $self->{'imax'}{$key};
}

