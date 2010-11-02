# Find complements of node
sub node_complements {
	# Parameters
	my $self = shift;

	# Process nodes
	my @complements = ();
	foreach my $n (@_) {
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		foreach my $e (@{$nodeobj->out()}) {
			push @complements, node2int($e->in(), $key)
				if ($graph->is_complement($e));
		}
	}

	# Return complements
	return uniq(sort(@complements));
}

