sub cmd_offset_align {
	my $self = shift;
	my $graph = shift;
	my $offsets = shift;

	# Check for auto offset
	if ($offsets eq "auto") {
		$graph->auto_offset();
		return 1;
	}

	# Process offsets
	while ($offsets =~ s/^\s+([-+=])?([a-z])(-?[0-9]+)//) {
		# Find sign, key, and number
		my $sign = $1 || "+";
		my $key = $2;
		my $number = 0 + ($3 || 0);

		# Set new offset
		if ($sign eq "+") {
			$graph->offset($key, $graph->offset($key) + $number);
		} elsif ($sign eq "-") {
			$graph->offset($key, $graph->offset($key) - $number);
		} elsif ($sign eq "=") {
			$graph->offset($key, $number);
		}

		# Check that offset is valid
		$graph->offset($key, 0) if ($graph->offset($key) < 0);

		# Set imin accordingly
		$graph->{'imin'}{$key} = $graph->offset($key);
	}

	# Report offsets
	print "offset " . 
		join(" ",
			map {"=$_" . $graph->offset($_)}
			sort(keys(%{$graph->{'graphs'}})))
		. "\n" if (! $self->quiet());


	# Update graph
	$self->cmd_return($graph);

	# Return with success
	return 1;
}
