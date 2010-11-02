sub delta_function {
	my $self = shift;
	$self->{'delta_function'} = shift() if (@_);
	return $self->{'delta_function'};
}
