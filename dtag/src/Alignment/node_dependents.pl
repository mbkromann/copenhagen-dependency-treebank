# node_dependents($self, @nodes) = @dependents
# 	- find dependents of node

sub node_dependents {
	# Parameters
	my $self = shift;

	# Process nodes
	my @dependents = ();
	foreach my $n (@_) {
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		foreach my $e (@{$nodeobj->out()}) {
			push @dependents, node2int($e->in(), $key)
				if ($graph->is_dependent($e));
		}
	}

	# Return governors
	return uniq(sort(@dependents));
}

