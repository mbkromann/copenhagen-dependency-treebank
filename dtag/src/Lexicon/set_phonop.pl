sub set_phonop {
	my $self = shift;
	my $name = shift;
	my $phonop = shift;

	return $self->{'phonops'}{$name} = $phonop;
}
