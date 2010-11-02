sub cmd_shell {
	my $self = shift;
	my $cmd = shift;

	# Execute shell command
	my $status = system($cmd);

	# Exit
	return 1;
}
