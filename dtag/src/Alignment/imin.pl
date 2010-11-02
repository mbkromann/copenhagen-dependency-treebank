sub imin {
	my $self = shift;
	my $key = shift;
	$self->{'imin'}{$key} = shift if (@_);
	return $self->{'imin'}{$key};
}

