sub subtypes { 
	my $self = shift;
	my $type = shift;
	return $self->{'sub'}{$type} || [];
}
