sub cmd_load_matches {
	my $self = shift;
	my $file = shift;

	# Read match file
	my $match = "";
	open("MATCH", "< $file") 
		|| return error("cannot open match-file for reading: $file");
	while(<MATCH>) {
		$match .= $_;
	}
	close("MATCH");

	# Convert match file to object, and print error messages
	my $mobj = eval("my $match");
	if ($@) {
		error($@);
	} else {
		$self->{'matches'} = $mobj;
		$self->{'match'} = 1;
	}

	# Close file
	print "opened match-file $file\n" if (! $self->quiet());

	# Return
	return 1;
}
