sub cmd_save {
	my $self = shift;
	my $graph = shift;
	my $ftype = shift || "";
	my $fname = shift || "";
	$fname =~ s/~/$ENV{HOME}/g;
	$ftype =~ s/^\s+//g;

    # Find type of file (-tag): look at ending, select .tag
	if (! $ftype) {
		# Default
		$ftype = (UNIVERSAL::isa($graph, 'DTAG::Alignment')) 
			? '-atag' : '-tag';

		# Other
		$ftype = '-tag' if ($fname =~ /\.tag$/);
		$ftype = '-atag' if ($fname =~ /\.atag$/);
		$ftype = '-alex' if ($fname =~ /\.alex$/);
		$ftype = '-tiger' if ($fname =~ /\.xml$/);
		$ftype = '-malt' if ($fname =~ /\.malt$/);
		$ftype = '-match' if ($fname =~ /\.match$/);
		$ftype = '-conll' if ($fname =~ /\.conll$/);
		$ftype = '-osdt' if ($fname =~ /\.osdt$/);
		$ftype = '-table' if ($fname =~ /\.table$/);
	}

	# Save file
	if ($ftype eq '-tag') {
		$self->cmd_save_tag($graph, $fname);
	} elsif ($ftype eq '-atag') {
		$self->cmd_save_atag($graph, $fname);
	} elsif ($ftype eq '-alex') {
		$self->cmd_save_alex($graph, $fname);
	} elsif ($ftype eq '-tiger') {
		$self->cmd_save_tiger($graph, $fname);
	} elsif ($ftype eq '-malt') {
		$self->cmd_save_malt($graph, $fname);
	} elsif ($ftype eq '-conll') {
		$self->cmd_save_conll($graph, $fname);
	} elsif ($ftype eq '-match') {
		$self->cmd_save_matches($fname);
	} elsif ($ftype eq '-osdt') {
		$self->cmd_save_osdt($graph, $fname);
	} elsif ($ftype eq '-table') {
		$self->cmd_save_table($graph, $fname);
	}

	# Return
	return 1;
}

