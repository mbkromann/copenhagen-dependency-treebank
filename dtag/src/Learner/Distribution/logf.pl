sub logf {
	my $self = shift;
	my $fx = $self->f(shift);
	return ($fx > 0) ? log($fx) : 1e200;
}
