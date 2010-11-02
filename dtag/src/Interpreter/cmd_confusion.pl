sub cmd_confusion {
	my ($self, $relset, $files, $add) = @_;
	my $confusions = $self->{'confusion'} = $self->{'confusion'} || {};

	# Initialize confusion tables
	my $confusion = $add ? ($self->{'confusion'}{$relset} || {}) : {};
	$confusions->{$relset} = $confusion;

	# Logging
	inform("Reading \"$relset\" confusion table from: $files");

	# Open files
	foreach my $file (split(/\s+/, $files)) {
		# Open confusion file (format: $rel $count $x%=$rel\t...)
		$file =~ s/^~/$ENV{HOME}/g;
		if (!  open(CONF, "<:encoding(utf8)", $file)) {
			warning("Cannot open file $file for reading\n");
			next;
		}

		# Read file
		my $relsethash = $self->{'relsets'}{$relset} || {};
		while (my $line = <CONF>) {
			chomp($line);
			my @fields = map {
				my $crel = $_; 
				my $rellist = $relsethash->{$crel};
				$rellist ? $rellist->[$REL_SNAME] : $crel;
			} split(/\t/, $line);
			my $rel = shift(@fields);
			$confusion->{$rel} = [@fields]
				if (defined($rel) && $rel ne "");
		}

		# Close file
		close(CONF);
	}

	# Return
	return 1;
}
