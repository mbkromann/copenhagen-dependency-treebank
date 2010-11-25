sub fpsfile {
	my $self = shift;
	my $type = shift;
	$type = "" if (! defined($type));
	return $self->var('fpsfile:' . $type, @_);
}
