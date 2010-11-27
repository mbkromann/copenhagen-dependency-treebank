sub cmd_show_align {
	my $self = shift;
	my $graph = shift;
	my $args = (shift() || "") . " ";
	my $option = shift() || "";

	# Process argument string
	my @graphs = ($graph);
	while ($args !~ /^\s*$/) {
		my ($imin, $imax) = (-1, -1);
		if ($args =~ s/^\s*(=?)([a-z])([-+]?[0-9]+)(\.\.([+-]?[0-9]+))?([^0-9])/$6/) {
			# Retrieve values
			my $key = $2;
			my $offset = $1 ? 0 : $graph->offset($key);
			my $keygraph = $graph->graph($key);
			next if (! $keygraph);

			# Compute $imin and $imax
			$imin = $3 + $offset;
			$imin = 0 if ($imin < 0);
			$imax = max($imax, $5 + $offset) if (defined($5));
			$imax = $graph->graph($key)->size()
				if ($imax < 0);

			# Set values in graph and keygraph
			$graph->var("imin")->{$key} = $imin;
			$graph->var("imax")->{$key} = $imax;
			$keygraph->var("imin", $imin);
			$keygraph->var("imax", $imax);
			push @graphs, $keygraph if (! grep {$_ eq $keygraph} @graphs);
		} else {
			$args =~ s/^.//;
		}
	}

	# Redisplay all graphs and keygraphs
	#print "Updating " . join(" ", map {$_->id()} @graphs) . "\n";
	foreach my $g (@graphs) {
		$self->cmd_return($g);
	}

	# Return
	return 1;
}
