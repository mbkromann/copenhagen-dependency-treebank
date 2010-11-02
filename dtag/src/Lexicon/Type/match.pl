sub match {
	my $self = shift;
	$self->lvar('_match', @_);
	return $self;
}
