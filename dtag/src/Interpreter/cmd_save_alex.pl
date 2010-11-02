sub cmd_save_alex {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Check that graph is an alignment
	if (! UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		error("no active alignment");
		return undef;
	}

	# Check that alignment has an alexicon
	if (! $graph->alexicon()) {
		error("no active alignment lexicon");
		return undef;
	}

	# Find lexicon and update file name
	my $alexicon = $graph->alexicon();
	$alexicon->file($file) if ($file);
	$file = $alexicon->file();

	# Open tag file
	open("ALEX", "> $file") 
		|| return error("cannot open alex-file for writing: $file");

	# Print XML file
	print ALEX
		$alexicon->write_alex();

	# Close file
	close("ALEX");
	print "saved alex-file $file\n" if (! $self->quiet());

	# Mark alexicon as being unmodified
	$alexicon->mtime(undef);

	# Return
	return 1;
}

