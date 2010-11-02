sub cmd_fixations {
	my $self = shift;
	my $graph = shift;
	my $fixid = shift;
	my $attrd = shift || "dur";
	my $attrg = shift || "cur";
	my $attrf = shift || $attrg;

	# Retrieve fixation graph
	my $fixgraph;
	if ($fixid =~ /^F\[[0-9]+\]$/) {
		# File already loaded with id $fixid
		my $fixindex = $self->gid2index($fixid);
		$fixgraph = $self->{'graphs'}->[$fixindex]
			if (defined($fixindex));
	} else {
		# Load fixations from file
		my $curgraph = 
		$fixgraph = DTAG::Graph->new($self);
        $fixgraph->file($fixid);
		$self->cmd_load_fix($fixgraph, $fixid, 1);
	}
	if (! defined($fixgraph)) {
		error("Could not find fixation graph $fixid\n");
		return 1;
	}

	# Assign fixation graph to graph
	$graph->var("fixations", []) 
		if (! defined($graph->var("fixations")));
	my $fixations = $graph->var("fixations");
	push @$fixations, [$fixgraph, $attrd, $attrg, $attrf, 0, 0, $fixgraph->size() - 1, $fixid];
	print "Added fixations $fixid to graph " . $graph->id() 
			. " (linking attribute: graph=$attrg fixations=$attrf)\n"
		if (! $self->quiet());

	# Return
	return 1;
}


