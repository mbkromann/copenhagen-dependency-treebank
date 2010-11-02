sub cmd_edgesplit {
	my $self = shift;
	my $command = shift;

	# Ensure that edgesplits array is present
	my $edgesplits = $self->var("edgesplits");
	$edgesplits = $self->var("edgesplits", []) 
		if (! $edgesplits);

	# Make command
	if ($command =~ /^\s*-clear\s+$/) {
		$self->var("edgesplits", []);
	} elsif ($command =~ /^\s*(s\/.*\/.*\/.*)\s*/) {
		push @$edgesplits, $1;
	} else {
		error("edgesplit: unknown regular expression $command\n");
	}

	# Return 1
	return 1;
}

