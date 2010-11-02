sub cmd_maptags {
	my $self = shift;
	my $graph = shift;
	my $mapfile = shift;
	my $invar = shift;
	my $outvar = shift;

	# Check that arguments are legal
	if (! (defined($invar) && defined($outvar))) {
		error("Usage: maptags [-map $mapfile] $invar $outvar\n");
	}

	# Read mapfile
	my $map = $self->{'maptags_map'} 
		= $self->{'maptags_map'} || {};
	my $missing = $self->{'maptags_missing'} 
		= $self->{'maptags_missing'} || {};
 
	if ($mapfile && -f $mapfile) {
		open(IFS, "<$mapfile") 
			|| return error("cannot open mapfile $mapfile");
		while (my $line = <IFS>) {
			chomp($line);
			my ($in, $out) = split(/\t/, $line);
			$map->{$in} = $out;
		}
		close(IFS);
	}

	# Convert words in graph
	for (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		if (! $node->comment()) {
			my $inval = $node->var($invar);
			next() if (! defined $inval);
			my $instring = lc($node->input());
			my $outval = $map->{$inval . ":" . $instring} || $map->{$inval};
			if (defined $outval) {
				$node->var($outvar, $outval);
			} else {
				$missing->{$inval} = 1;
			}
		}
	}

	# Add new var to vars
	$self->cmd_vars($graph, $outvar);

	# Print input values that lack from map
	print "Undefined input tags: "
		. join(" ", sort(keys(%$missing))) . "\n";

	return 1;
}
