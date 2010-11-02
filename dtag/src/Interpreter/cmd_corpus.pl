sub cmd_corpus {
	my $self = shift;
	my $cmd = shift || "";

	# Update corpus files, if $cmd is specified
	if ($cmd !~ /^\s*$/) {
		# Save glob
		$self->{'corpus_glob'} = $cmd;

		# Find list of globs
		my @globs = split(/\s+/, $cmd);
		my @files = ();

		# Expand globs
		while (@globs) {
			push @files, glob(shift(@globs));
		}

		# Filter out unreadable files and save them
		@files = grep { -r $_ } @files;
		$self->{'corpus'} = \@files;
	}

	# Print files
	$self->print("corpus", "info", 
		"corpus files =" . ($self->{'corpus_glob'} || "") . "\n");

	# Return
	return 1;
}


