sub cmd_comment {
	my $self = shift;
	my $graph = shift;
	my $posr = shift;
	my $comment = shift;

	# Check range
	my $pos = (! defined($posr) || $posr eq "") 
		? $graph->size()
		:  ($posr || 0) + $graph->offset(); 

	# Create new node
	my $N = Node->new();
	$N->input($comment);
	$N->comment(1);

	# Add new node to graph, and mark graph as modified
	$graph->node_add($pos, $N);

	# Mark graph as modified
	$graph->mtime(1);
	return 1;
}
