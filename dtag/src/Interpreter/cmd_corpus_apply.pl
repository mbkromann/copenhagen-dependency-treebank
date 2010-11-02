sub cmd_corpus_apply {
	my $self = shift;
	my $cmd = shift || "";
	my $graph = $self->graph();

	# Process options
	my $time = - time();
	my $progress = "";

	# Solve DNF-query for all files in corpus
	my $iostatus = $|; $| = 1; my $c = 0;
	my $findfiles = $self->{'corpus'};
	my $laststatus = time() - 1;
	foreach my $f (@$findfiles) {
		# Load new file from corpus, if this is a corpus search 
		$self->cmd_load($graph, undef, $f);
		$graph = $self->graph();
		$self->do($cmd);

		# Print progress report 
		if (! $self->quiet()) {
	 		if (time() > $laststatus + 0.5 ) {
				$laststatus = time();
				my $blank = "\b" x length($progress);
				my $percent = int(100 * $c / (1 + $#$findfiles));
				$progress = 
					sprintf('Processed %02i%%. Elapsed: %s. ETA: %s.',
					$percent,
					seconds2hhmmss(time()+$time),
					seconds2hhmmss(int((100-$percent) 
							/ ($percent || 1) * (time()+$time))));
				$self->print("corpus-apply", "status", $blank . $progress);
			}
			++$c;
		}

		# Abort on request
		last() if ($self->abort());
	}
	print "\b" x length($progress)
		. " " x length($progress) 
		. "\b" x length($progress)
			if (! $self->quiet());
	$| = $iostatus;

    # Print search statistics
	$time += time();
	print "corpus-apply took " . seconds2hhmmss($time) 
		. " seconds to execute \"$cmd\".\n" if (! $self->quiet());


	# Restore old fpsfile
	#$self->{'fpsfile'} = $oldfpsfile;

	# Return
	return 1;
}

