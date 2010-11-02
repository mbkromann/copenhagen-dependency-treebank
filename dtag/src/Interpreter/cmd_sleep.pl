sub cmd_sleep {
	my $self = shift;
	my $seconds = shift || "0";

	sleep($seconds);
	return 1;
}
