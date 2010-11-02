sub pweight {
	my $self = shift;
	$self->{'pweight'} = shift if (@_);
	return $self->{'pweight'};
}

