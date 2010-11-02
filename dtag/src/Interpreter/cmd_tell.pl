sub cmd_tell {
	my $self = shift;
	my $table = shift;
	my $file = shift || "";

	if (! defined($table)) {
		$table = "$file";
		$table =~ s/\s+//g;
	}

	# Get table list
	my $tablenames = $self->{'tablenames'} = $self->{'tablenames'} || {};
    my $tables = $self->{'tables'} = $self->{'tables'} || [];

	# Close old table with given name, if it exists
	$self->cmd_told($table);

	# Open new filehandle and register as table
	$file =~ s/^~/$ENV{HOME}/g;
	open(my $fh, ">:encoding(utf8)", $file)
		|| ( warning("cannot open file \"$file\" for writing") && return 1);
	push @$tables, $fh;
	$tablenames->{$table} = $fh;

	# Info
	inform("Opened file \"$file\" as stream \"$table\"")
		if (! $self->quiet());

	# Return
	return 1;
}
