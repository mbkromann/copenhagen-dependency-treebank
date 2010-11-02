sub loop {
	my $self = shift;
	my $line = "";

	# Increase loop count and create prompt
	$self->{'loop_count'} += 1;
	my $prompt = ('>' x $self->{'loop_count'}) . ' ';

	# Loop until exit command is reached
	while ($self->{'loop_count'} == 1 || 
		($line ne "exit" && $line ne "quit" 
			&& $line ne "resume" && $line ne "abort")) {
		$self->abort(0);

		# Find next line to process
		my $server = $self->var('server');
		if (! $server) {
			$line = $self->term()->readline($prompt, $self->nextcmd());
		} else {
			my @requests = sort(glob($server));
			$line = "sleep 0.1";

			# Find first file in queue
			while (@requests) {
				my $file = shift(@requests);
				if (-r $file && -f $file && ($file !~ /~$/)) {
					my $tmp = $file . '~';
					rename($file, $tmp);
					$line = "script $tmp";
					@requests = ();
				}
			} 
		}

		# Process line
		$line = "exit" if (! defined($line));
		$self->nextcmd("");
		eval { $self->do($line) };
		warn $@ if $@;
	}

	# Decrease the loop count
	$self->{'loop_count'} -= 1;
}
