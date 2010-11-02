sub cmd_load_malt {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Open tag file
	open("MALT", "< $file") 
		|| return error("cannot open MALT-file for reading: $file");
	
	# Close current graph, if unmodified
	$self->cmd_load_closegraph($graph);

	# Create new graph
	$graph = DTAG::Graph->new($self);
	$graph->file($file);
	push @{$self->{'graphs'}}, $graph;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;
	$graph->vars()->{'msd'} = undef;

	# Read MALT file line by line
	my $offset = 0;
	my $edges = [];
	my $pos = 0;
    while (my $line = <MALT>) {
		# Process MALT line
        chomp($line);
		my ($input, $msd, $head, $type) = split(/	/, $line);

		# Create node and add it to graph
		my $n = Node->new();
		my $in = $graph->size();
		if ($line) {
			# Setup node
			$n->var('msd', $msd);
			$n->input($input);
			$graph->node_add($in, $n);

			# Create edge
			my $e = Edge->new();
			$e->in($in);
			$e->type($type);
			$e->out($head - 1 + $offset);
			push @$edges, $e if ($head);
		} else {
			$n->comment(1);
			$n->input('</s>');
			$offset = $graph->size();
			#$graph->node_add($in, $n);
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Add edges
	foreach my $e (@$edges) {
		$graph->edge_add($e) 
			if ($e->out() >= 0);
	}

	# Close MALT file
	close("MALT");
	$self->cmd_return($graph);
	return 1;
}
