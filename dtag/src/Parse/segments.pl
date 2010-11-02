sub segments {
	my $self = shift;
	$self->{'segments'} = shift if (@_);
	return $self->{'segments'};
}
