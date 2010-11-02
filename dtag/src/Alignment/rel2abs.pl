sub rel2abs {
	my $self = shift;
	my $key = shift;
	my $relative = shift;

	return $relative + ($self->{'offsets'}{$key} || 0);
}

