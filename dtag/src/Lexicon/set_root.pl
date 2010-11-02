sub set_root {
	my $self = shift;
	my $name = shift;
	my $root = shift;

	return $self->{'roots'}{$name} = $root;
}
