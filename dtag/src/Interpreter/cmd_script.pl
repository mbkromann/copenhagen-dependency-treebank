sub cmd_script {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Replace ~ with home directory
	$file =~ s/~/$ENV{HOME}/g;

	# Open script file
	open("SCRIPT", "< $file")
		|| return error("cannot open file for reading: $file");
	

	# Read script file line by line, and add to "todo"
	my $todo = $self->var('todo', []);
	while (my $line = <SCRIPT>) {
		# Ignore comments and blank lines
		if (! ($line =~ /^\s*$/)) {
			push @$todo, $line;
		} 
	}

	# Close file, call resume, and return
	close("SCRIPT");
	$self->cmd_resume($graph, 0);

	# Return
	return 1;
}
