sub cmd_merge {
	my $self = shift;
	my $oldgraph = shift;
	my $files = shift;

	# Load all files and compute reliability scores
	my $graphs = [];
	foreach my $file (glob($files)) {
		# Load file
		print "Loading $file\n";
		$self->cmd_load(DTAG::Graph->new($self), undef, $file);
		push @$graphs, $self->graph();
	}

	# Create new graph
	$self->cmd_new();
	my $graph = $self->graph();

	# Create nodes in new graph
	$self->merge_nodes($graph, $graphs);

	# Create edges in new graph
	$self->merge_edges($graph, $graphs);

	# Return
	return 1;
}


