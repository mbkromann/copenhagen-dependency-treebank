sub cmd_output {
	my $self = shift;
	$self->var('output', @_);
	return 1;
}
