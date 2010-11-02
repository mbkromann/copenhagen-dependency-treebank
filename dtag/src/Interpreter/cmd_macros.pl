sub cmd_macros {
	my $self = shift;
	my $name = shift;
	my $command = shift;

	# Print macros
	foreach my $m (sort(keys(%{$self->{'macros'}}))) {
		print "macro[$m]: " . $self->{'macros'}{$m} . "\n";
	}

	# Return
	return 1;
}
