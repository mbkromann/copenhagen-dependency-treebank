sub hierarchy {
	my $self = shift;
	$self->{'hierarchy'} = shift if (@_);
	return $self->{'hierarchy'};
}
