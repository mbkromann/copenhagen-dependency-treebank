sub quiet {
	my $self = shift;
	return $self->var('quiet', @_);
}
