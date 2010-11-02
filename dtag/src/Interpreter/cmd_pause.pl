sub cmd_pause {
	my $self = shift;

	# Set ntodo variable to 0
	$self->var('ntodo', 0);

	# Return
	return 1;
}
