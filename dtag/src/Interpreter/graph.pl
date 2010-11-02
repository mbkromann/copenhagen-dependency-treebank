sub graph {
	my $self = shift;
	$self->{'graph'} = shift if (@_);
	return $self->{'graphs'}[$self->{'graph'} || 0];
}
