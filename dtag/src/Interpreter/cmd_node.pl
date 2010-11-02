sub cmd_node {
	my $self = shift;
	my $graph = shift;
	my $posr  = shift;
	my $input = shift;
	my $varstr = shift;

	# Check node -off
	return error("node creation blocked") 
		if ($graph->{'block_nodeadd'});

	# Check range
	my $pos = (! defined($posr) || $posr eq "") 
		? $graph->size()
		:  ($posr || 0) + $graph->offset(); 

	# Create new node
	my $N = Node->new();
	$N->input($input);

	# Parse variable specification
	my $vars = $self->varparse($graph, $varstr, 1);
	foreach my $var (keys %$vars) {
		$N->var($var, $vars->{$var}) if (defined($vars->{$var}));
	}

	# Add new node to graph, and mark graph as modified
	$graph->node_add($pos, $N);

	# Mark graph as modified
	$graph->mtime(1);
	return 1;
}
