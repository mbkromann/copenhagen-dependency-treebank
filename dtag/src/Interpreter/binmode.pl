sub binmode {
	my $self = shift;
	return $self->var('binmode', @_);
}
