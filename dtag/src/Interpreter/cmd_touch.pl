sub cmd_touch {
	my $self = shift;
	my $graph = shift;

	# Touch graph
	$graph->mtime(1);

	# Return 
	return 1;
}
