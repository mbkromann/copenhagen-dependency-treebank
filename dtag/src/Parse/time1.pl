sub time1 {
	my $self = shift;
	$self->{'time1'} = shift if (@_);
	return $self->{'time1'};
}
