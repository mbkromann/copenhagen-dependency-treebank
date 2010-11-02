sub node_incomplete {
	my $self = shift;
	my $key = shift;
	my $i1 = shift || 0;

	# Find graph
	my $graph = $self->graph($key);

	# Go through all non-comment nodes in graph
	for (my $i = $i1; $i < $graph->size(); ++$i) {
		return $i if (! ($graph->node($i)->comment()
			|| (grep {$_->creator() > -100} @{$self->node($key, $i)})));
	}

	# No node found: return last node in graph
	return $graph->size() - 1;
}
