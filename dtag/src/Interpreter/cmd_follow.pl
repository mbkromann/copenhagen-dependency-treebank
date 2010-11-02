sub cmd_follow {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Update follow file and print
	$graph->fpsfile($file);
	$self->cmd_return($graph);

	# Return
	return 1;
}
