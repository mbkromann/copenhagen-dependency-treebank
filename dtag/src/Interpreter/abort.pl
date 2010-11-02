sub abort {
	my $self = shift;
	$self->{'abort'} = shift if (@_);
	return $self->{'abort'};
}
