sub cmd_resume {
	my $self = shift;
	my $graph = shift;
	my $ntodo = shift;
	my $history = shift;

	# Set number of commands to perform
	my $todo = $self->var('todo');
	$self->var('ntodo', $ntodo || -1);
	
	# Read todo-list line by line, and perform do
	while ($self->var('ntodo') && @$todo) {
		# Perform line
		my $line = shift(@$todo);
		$self->var('ntodo', $self->var('ntodo') - 1)
			if (! ($line =~ /^\s*#.*$/));
		print "> $line" if (! ($self->quiet() || $line =~ /\\\s*/ || $line =~ /^\s*echo\s+/));
		$self->do($line, $history);

		# Abort if requested
		$self->var('ntodo', 0) if ($self->abort());
	}
	if (! $self->var("noupdate")) {
		$self->cmd_return() 
	}

	# Return
	return 1;
}
