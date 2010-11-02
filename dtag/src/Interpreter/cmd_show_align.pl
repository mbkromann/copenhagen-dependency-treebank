sub cmd_show_align {
	my $self = shift;
	my $graph = shift;
	my $args = (shift() || "") . " ";
	my $option = shift() || "";

	# Process argument string
	while ($args !~ /^\s*$/) {
		my ($imin, $imax) = (-1, -1);
		if ($args =~ s/^\s*([a-z])([0-9]+)(-([0-9]+))?([^0-9])/$5/) {
			# Retrieve values
			my $key = $1;
			my $keygraph = $graph->graph($key);
			next if (! $keygraph);
			$imin = ($imin == -1) 
				? $2 + $graph->offset($key) 
				: min($imin, $2 + $graph->offset($key));
			$imax = max($imax, $4 + $graph->offset($key)) if (defined($4));
			$imax = $graph->graph($key)->size()
				if ($imax < 0);
				

			# Set values in graph
			$graph->var("imin")->{$key} = $imin;
			$graph->var("imax")->{$key} = $imax;
		} else {
			$args =~ s/^.//;
		}
	}

	# Redisplay
	$self->cmd_return($graph);

	# Return
	return 1;
}
