# Find complement governors for node
sub node_complement_governors {
	# Parameters
	my $self = shift;

	# Process nodes
	my @governors = ();
	foreach my $n (@_) {
		my ($node, $key) = int2node($n);
		my $graph = $self->graph($key) || next();
		my $nodeobj = $graph->node($node) || next();
		foreach my $e (@{$nodeobj->in()}) {
			push @governors, node2int($e->out(), $key)
				if ($graph->is_complement($e));
		}
	}

	# Return governors
	return uniq(sort(@governors));
}

