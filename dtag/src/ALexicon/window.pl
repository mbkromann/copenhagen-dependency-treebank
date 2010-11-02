sub window {
	my $self = shift;
	return $self->var('window', @_) || 20;
}
