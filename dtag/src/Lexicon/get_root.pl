sub get_root {
	my $self = shift;
	my $name = shift;
	return $self->{'roots'}{$name};
}
