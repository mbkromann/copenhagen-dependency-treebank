sub abs2rel {
	my $self = shift;
	my $key = shift;
	my $abs = shift;

	return $abs - ($self->{'offsets'}{$key} || 0);
}

