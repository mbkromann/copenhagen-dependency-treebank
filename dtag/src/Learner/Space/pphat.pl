sub pphat {
	my $self = shift;
	$self->{'pphat'} = shift if (@_);
	return $self->{'pphat'};
}
