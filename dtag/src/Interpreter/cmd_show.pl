sub cmd_show {
	my $self = shift;
	my $graph = shift;
	my $args = (shift() || "") . " ";
	my $option = shift() || "";
	my $imid = shift();

	# Calculate ranges to show
	my ($imin, $imax) = (-1, -1);
	my $include = {};
	my $exclude = {};

	# Process argument string
	while ($args !~ /^\s*$/) {
		if ($args =~ s/^\s*=?([0-9]+)(-([0-9]+))?([^0-9])/$4/) {
			$imin = ($imin == -1) 
				? $1 + $graph->offset() 
				: min($imin, $1 + $graph->offset());
			$imax = max($imax, $3 + $graph->offset()) if (defined($3));
		} elsif ($args =~ s/^\s*([+-])([0-9]+)(-([0-9]+))?([^0-9])/$5/) {
			my ($ie, $i1, $i2) = ($1, $2, $4 || $2);
			$imin = min($imin, $i1 + $graph->offset()) if ($ie eq "+");
			$imax = max($imax, $i2 + $graph->offset()) if ($ie eq "+");

			# Update include/exclude hash within $imin and $imax
			my $i = $i1;
			for(my $i = $i1; $i <= min($imax, $i2); ++$i) {
				$include->{$i} = 1 if ($ie eq "+");
				$exclude->{$i} = 1 if ($ie eq "-");
			}
		} else {
			$args =~ s/^.//;
		}
	}

	# Process all included nodes, if -yield or -component option is given
	if ($option =~ /^-[cy]$/) {
		# Process all include nodes
		my $new = {};
		foreach my $i (keys(%$include)) {
			if ($option =~ /^-y/) {
				$graph->yields($new, $i);
			} elsif ($option =~ /^-c/) {
				$graph->component($i, $new);
			}
		}

		# Add all new include nodes to $include and update $imin and $imax
		foreach my $i (keys(%$new)) {
			$include->{$i} = 1;
			$imin = ($imin == -1) ? $i : min($imin, $i);
			$imax = max($imax, $i);
		}
	}

	# Set new values of $imin and $imax in $graph, and redisplay
	$graph->var('imin', $imin);
	$graph->var('imax', $imax);
	$graph->var('imid', defined($imid) ? $imid + $graph->offset() : $imin);
	$graph->include(scalar(%$include) ? $include : undef);
	$graph->exclude(scalar(%$exclude) ? $exclude : undef);
	$self->cmd_return($graph);

	# Return
	return 1;
}
