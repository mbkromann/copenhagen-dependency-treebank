sub cmd_server {
	my $self = shift;

	# Store server directory
	$self->var('server', shift);
	return 1;
}
