sub weight {
	my $self = shift;
	$self->{'weight'} = $self->{'rweight'} = shift if (@_);
	return $self->{'weight'};
}

