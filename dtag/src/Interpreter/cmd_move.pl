sub cmd_move {
	my $self = shift;
	my $graph = shift;
	my $fromr = shift;
	my $tor = shift;

	# Compute absolute positions
	my $from = (! defined($fromr) || $fromr eq "")
		? $graph->size() :  ($fromr || 0) + $graph->offset();
	my $to = (! defined($tor) || $tor eq "")
		? $graph->size() :  ($tor || 0) + $graph->offset();

	# Find node object
	my $node = $graph->node($from);
	return error("Non-existent node: $from") 
		if ((! defined($from)) || (! ref($node)));
	
	# Save edges and delete node
	my $edges = [@{$node->in()}, @{$node->out()}];
	$self->cmd_del($graph, $from);

	# Add node to graph again at new place
    $graph->node_add($to, $node);

	# Reconstruct edges
	foreach my $edge (@$edges) {
		$edge->in(node_moved($edge->in(), $from, $to));
		$edge->out(node_moved($edge->out(), $from, $to));
		$graph->edge_add($edge);
	}

	# Recompile node ids
	$graph->compile_ids();

	# Mark graph as modified
    $graph->mtime(1);

	# Return
	return 1;
}

sub node_moved {
	my $n = shift;
	my $from = shift;
	my $to = shift;

	# Compute position of moved node
	if ($n == $from) {
		return $to;
	} 
	
	# Compute position of any other node in two steps
	my $n1 = ($n > $from) ? $n - 1 : $n;
	my $n2 = ($n1 >= $to) ? $n1 + 1 : $n1;
	return $n2;
}

