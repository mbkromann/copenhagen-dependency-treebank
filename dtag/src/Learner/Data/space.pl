sub space {
	my $self = shift;
	$self->{'space'} = shift if (@_);
	return $self->{'space'};
}
