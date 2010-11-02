sub edge {
	my $self = shift;
	my $e = shift;
	return $self->var('edges')->[$e];
}
