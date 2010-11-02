sub cmd_compound {
	my $self = shift;
	my $graph = shift;
	my $key = shift || "";
	my $noder = shift;
	my $compound = shift || "";
	my $ocompound = $compound . "";
	$compound =~ s/^\s+//g;

	# Autoformat compound
	$compound = compound_autonumber($compound);

	# Now we have the renumbered segment
	my $cmd = "";
	if (UNIVERSAL::isa($graph, 'DTAG::Graph') && (! $key)) {
		# Dependency graph
		my $node = defined($noder) ? $noder + $graph->offset() : undef;
		my $N = $graph->node($node);
		if ($compound) {
			$N->var('compound', $compound);
			$graph->vars()->{'compound'} = 1;
		}
		
		# Errors: non-existent node, or comment node
		return error("Non-existent node: $noder") if (! $N);
		return error("Node $noder is a comment node.") if ($N->comment());
		my $default = $N->input();
		if ($ocompound && ($compound eq "")) {
			$N->var('compound', '');
		}

		# Mark graph as modified and add existing compound
		$compound = $N->var('compound') || $N->input();
		$cmd = "segment $noder $compound";
		print "segment $key$noder $compound\n";
	} elsif (UNIVERSAL::isa($graph, 'DTAG::Alignment') && ($key)) {
		# Alignment: check that key is valid
		my $ngraph = $graph->graph($key);
		return error("Non-existent graph key \"$key\"") if (!  $ngraph);

		# Check that node is valid
		my $nodeabs = $noder + ($graph->offset($key) || 0);
		my $node = $ngraph->node($nodeabs);
		return error("Non-existent node \"$key$noder\"") if (! $node);

		# Retrieve compound from graph, if non-existent
		my $compounds = $graph->{'compounds'};
		my $default = $node->var('compound') || $node->input() || "";
		if (! $compound) {
			$compound = $compounds->{$key . $nodeabs} || $default;
			$compound = $default if ($ocompound =~ /^\s+$/);
		}

		# Remove compound if equal to graph compound or input
		if ($ocompound && ($compound eq $default)) {
			delete $compounds->{$key . $nodeabs};
		} else {
			$compounds->{$key . $nodeabs} = $compound;
		}

		# Mark graph as modified and add existing compound
		$cmd = "segment $key$noder $compound";
		print "segment $key$noder=$compound\n";
	}

	# Update command line history and graph
	if (! $ocompound) {
		$self->nextcmd($cmd);
	} else {
		 $self->term()->addhistory($cmd);
	}
	$graph->mtime(1);

	# Return
	return 1;
}

