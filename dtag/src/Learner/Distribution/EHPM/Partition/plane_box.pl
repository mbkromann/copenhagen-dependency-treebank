sub plane_box {
	my $self = shift;
	$self->{'plane_box'} = shift if (@_);
	return $self->{'plane_box'};
}
