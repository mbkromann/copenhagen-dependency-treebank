sub deparse {
	my $self = shift;
	my $file = shift;

	# Retrieve all edges in the graph
	my $edges = [];
	$self->do_edges(sub {my $e = shift; my $L = shift; push @$edges, $e;}, 
		$edges); 
	
	# Sort edges
	$edges = [
		sort {(max($a->in(), $a->out()) <=> max($b->in(), $b->out()))
			|| (min($a->in(), $a->out()) <=> min($b->in(), $b->out()))}
		@$edges
	];

	# Print edges
	open(CMD, ">$file");
	my $n = 0;
	push @$edges, "";
	foreach my $e (@$edges) {
		# Print missing nodes
		my $nmax = $e ? max($e->in(), $e->out()) : $self->size() - 1;
		for (; $n <= $nmax; ++$n) {
			my $node = $self->node($n);
			if ($node->comment()) {
				print CMD "comment\n";
			} else {
				print CMD "node " . $node->input() . "\n";
			}
		}

		# Print edge
		print CMD "edge " . $e->in() . " " . $e->type() . " " . $e->out() . "\n"
			if ($e); 
	}
	close(CMD);
}
