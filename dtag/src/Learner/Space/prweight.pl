sub prweight {
	my $self = shift;
	$self->{'prweight'} = shift if (@_);
	return $self->{'prweight'};
}

