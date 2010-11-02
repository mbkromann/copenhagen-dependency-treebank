sub cmd_pstep {
	my $self = shift;
	my $graph = shift;
	my $step = shift;
	$step = "+1" if (! defined($step));

	# Set step in graph
	my $ostep = $graph->pstep() || 0;
	$graph->pstep($1) if ($step =~ /^([0-9]+)$/);
	$graph->pstep($ostep + $1) if ($step =~ /^\+([0-9]+)$/);
	$graph->pstep($ostep - $1) if ($step =~ /^-([0-9]+)$/);
	print "pstep=" . $graph->pstep() . "\n";

	# Update graph
	$self->cmd_return($graph);

	# Return
	return 1;
}
