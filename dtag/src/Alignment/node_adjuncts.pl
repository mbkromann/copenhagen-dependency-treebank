# Find adjuncts of node
sub node_adjuncts {
	# Parameters
	my $self = shift;

	# Process nodes
	my @adjuncts = ();
	foreach my $n (@_) {
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		foreach my $e (@{$nodeobj->out()}) {
			push @adjuncts, node2int($e->out(), $key)
				if ($graph->is_adjunct($e));
		}
	}

	# Return adjuncts
	return uniq(sort(@adjuncts));
}

