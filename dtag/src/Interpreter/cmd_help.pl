sub cmd_help {
	my $self = shift;
	my $cmd = shift;

	if ($cmd) {
		if (defined($commands->{$cmd})) {
			print print_cmd($cmd);
		} else {
			error("Unknown command $cmd");
		}
	} else {
		foreach my $key (sort(keys %$commands)) {
			print print_cmd($key);
		}
	}

	return 1;
}

sub print_cmd {
	my $cmd = shift;
	return colored("$cmd: " . ($commands->{$cmd}[1] || ""), "bold") . "\n    " 
		. ($commands->{$cmd}[0] || "") . "\n";
}


