my $exit_unsaved = 0;

sub cmd_exit {
	my $self = shift;
	my $graph = shift;
	my $really_quit = shift;

	# Only exit from the outer loop
	if ($self->{'loop_count'} > 1) {
		return 1;
	}

	# Save file if modified
	print "\n";
	if ($graph && $graph->mtime() && $exit_unsaved + 60 < time() 
			&& ($really_quit || "") ne "!") {
		warning("You have unsaved graphs!\nType 'exit' or 'exit!' if you really want to quit...");
		$exit_unsaved = time();
		return 1;
	} 

	# Close lexicon
	my $lex = $self->lexicon();
	$lex->close() if ($lex);

	# Close viewers
	local $SIG{INT} = 'IGNORE';
	kill('INT', -$$);

	# Delete follow files
	unlink($graph->fpsfile()) if ($graph && $graph->fpsfile());
	unlink($self->fpsfile()) if ($self && $self->fpsfile());

	# Close cmdlog
	my $cmdlog = $self->var("cmdlog");
	if (defined($cmdlog)) {
	 	print $cmdlog "\n# close cmdlog: " 
			. (`date +'%Y.%m.%d-%H.%M'` || "???") . "\n";
		close($cmdlog);
		$self->var("cmdlog", undef);
	}

	# Kill viewers
	my $cmd = "ps e -w | grep dtag-$$- | grep -v grep | sed -e 's/^ //g' |cut -f1 -d\' \' | xargs -r kill";
	#print "Closing viewers with: $cmd\n";
	system($cmd);

	# Exit
	exit();
}
