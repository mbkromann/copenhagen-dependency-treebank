sub as_string {
	my $self = shift;
	return $self->in() . " " . $self->type() . " " . $self->out();
}
