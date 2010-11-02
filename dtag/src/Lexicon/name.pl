sub name {
	my $self = shift;
	$self->{'name'} = shift if (@_);
	return $self->{'name'};
}
