sub mass {
	my $self = shift;
	return $self->var('mass', @_) || 0;
}

