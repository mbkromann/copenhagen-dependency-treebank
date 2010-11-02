sub space_box {
	my $self = shift;

	# Set value
	$self->{'space_box'} = shift if (@_);

	# Return value
	return $self->{'space_box'};
}
