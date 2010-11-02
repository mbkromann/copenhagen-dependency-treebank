sub cmd_autoevaluate {
	my $self = shift;
	my $graph = shift;
	my $atagfile = shift;

	if (UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		# Check that there is an active alignment lexicon
		if (! $graph->alexicon()) {
			error("no current alignment lexicon");
			return 1;
		}

		# Load new alignment file if it exists
		my $copy;
		if ($atagfile) {
			print "Using template $atagfile\n";
			$self->cmd_load_atag($graph, $atagfile);
			$copy = $self->graph();
		}

		# Call autoevaluate on alignment lexicon
		$copy = $graph->alexicon()->autoevaluate($graph, $copy);
		push @{$self->{'graphs'}}, $copy;
    	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	    # Update graph
	    $self->cmd_return($copy);
		return 1;
	} else {
		error("DTAG graphs do not support autoevaluation");
		return 1;
	}

	# Return
	return 1;
}
