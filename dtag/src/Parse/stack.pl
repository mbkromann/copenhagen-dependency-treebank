sub stack {
	my $self = shift;
	if (@_) {
		$self->{'stack'} = shift;
		$self->stackhash(undef);
	}
	return $self->{'stack'};
}
