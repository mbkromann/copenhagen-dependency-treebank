sub space {
	my $self = shift;

	# Set value
	$self->{'space'} = shift if (@_);

	# Return value
	return $self->{'space'};
}
