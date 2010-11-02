sub cmd_perl {
	my $self = shift;
	my $cmd = shift;
	my $file = shift;
	my $verbose = shift;
	my $corpus = shift;

    my $time = - time();

	# Read command from file, if desired
	if ($file) {
		my @files = split(/ /, $cmd);
		$cmd = "";
		foreach my $f (@files) {
			if (-r $f) {
				open(FILE, "<$f")
					|| return error("cannot open script file for reading: $f");
				while (my $line = <FILE>) {
					$cmd .= $line;
				}
				close(FILE);
			}
		}
	}

	# Process current graph or all files in corpus
    my $iostatus = $|; $| = 1; my $c = 0;
	my $progress = "";
	my $corpusfiles = $corpus
		? $self->{'corpus'} 
		: [$self->graph()->id()];
	my $graph = $self->graph();
	foreach my $f (@$corpusfiles) {
        # Print progress report 
        if ($corpus && ! $self->quiet()) {
            print " \b\b" x length($progress);
            my $percent = int(100 * $c / (1 + $#{@$corpusfiles}));
            $progress = sprintf('Searched %02i%%. Elapsed: %s. ETA: %s. File: %s',
                $percent,
                seconds2hhmmss(time()+$time),
                seconds2hhmmss(int((100-$percent) 
                        / ($percent || 1) * (time()+$time))),
				$f);
            print $progress;
            ++$c;
        }

		# Load new file from corpus, if desired
		$self->cmd_load($graph, undef, $f) if ($corpus);
		$graph = $self->graph();

		# Prepend command with initializing code
		@perl_args = ($self, $graph, $self->lexicon());
		my $pcmd = 'my $L = pop(@perl_args); my $G = pop(@perl_args); '
				. 'my $I = pop(@perl_args); ' . $cmd;

		# Execute command
		my $value = eval($pcmd);

		# Print result of command and any errors
		$value = 'undef' if (! defined($value));
		my $str = ($verbose ? "return: $value\n" : "")
			. ($@ ? "errors: " . $@ : "");
		print $str . "\n"
			if (! $corpus && ! $self->quiet());

		# Abort if requested
		last() if ($self->abort());
	}
    print "\b" x length($progress);
	
	# Return
	return 1;
}
