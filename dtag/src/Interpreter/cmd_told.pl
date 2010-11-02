sub cmd_told {
	my $self = shift;
	my $table = shift;
	
	# Find table data
	my $tablenames = $self->{'tablenames'} = $self->{'tablenames'} || {};
	my $tables = $self->{'tables'} = $self->{'tables'} || [];

	# Find last defined table if $table is undefined
	if (! $table) {
		return 1 if ($#$tables < 0);
		my $lfh = $tables->[$#$tables];
		foreach my $t (keys(%$tablenames)) {
			$table = $t if ($tablenames->{$t} eq $lfh);
		}
	}
	return 1 if (! defined($table));

	# Find file handle
	my $fh = $self->{'tablenames'}{$table};

	# Close table
	if ($fh) {
		$self->{'tables'} = [grep {$_ ne $fh} @{$self->{'tables'}}];
		delete $self->{'tablenames'}{$table};
		close($fh);
		inform("Closing stream \"$table\"")
			if (! $self->quiet());
	}

	# Return 1
	return 1;
}

