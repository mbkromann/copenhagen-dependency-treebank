sub cmd_echo {
	my $self = shift;
	my $table = shift;
	my $string = shift;

	# Check whether table exists
	$string =~ s/\\n/\n/g;
	if (! defined($table)) {
		print $string;
	} else {
		my $tablenames = $self->{'tablenames'} || {};
		my $tables = $self->{'tables'} || [];
		my $ofh = $table ? $tablenames->{$table} : 
			($#$tables >= 0 ? $tables->[$#$tables] : undef);
		if (! defined($ofh)) {
			error("The table " . (defined($table) ? $table : "undef") . " does not exist, or has been closed.");
		} else {
			print $ofh $string;
		}
	}

	# Return 
	return 1;
}
