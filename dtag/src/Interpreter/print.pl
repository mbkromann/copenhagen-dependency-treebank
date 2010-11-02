sub print {
	my $self = shift;

	# Originating procedure
	my $facility = shift;		

	# Importance of message: error|warning|result|debug
	my $level = shift;

	# Message to be printed
	my $message = shift;

	# Print message
	print encode_utf8($message)
		if (! ($level eq "info" && $self->quiet()));
}
