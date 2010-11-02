sub cmd_macro {
	my $self = shift;
	my $name = shift;
	my $command = shift;

	# Add/delete macro
	if ($command) {
		$self->{'macros'}{$name} = $command;
	} else {
		delete $self->{'macros'}{$name};
	}

	# Return
	return 1;
}
