sub eq {
	my $self = shift;
	my $alex = shift;
	return $self->match($alex->out(), $alex->type(), $alex->in());
}

