sub cmd_return {
	my $self = shift;
	my $graph = shift || $self->graph();

	# Do nothing if "noview" is set
	return 1 if ($self->var("noview"));

	# Send update command to graph
	$graph->update();

	# Print follow file
	$self->cmd_print($graph, undef, 1)
		if ($self->{'viewer'});
	if ($graph->var("gedit")) {
		my $lineno = $graph->var('imid') || 0;
		$self->cmd_gedit($graph, $lineno);
	}
	return 1;
}
