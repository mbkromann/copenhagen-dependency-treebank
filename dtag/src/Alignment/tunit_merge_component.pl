sub tunit_merge_component {
	# Parameters
	my ($self, $tunits, $n) = @_;

	# Visit all nodes that transitively dominate $n depth-first, and
	# construct a reverse graph $revgraph of the subgraph consisting
	# of all edges that dominate $n. Visited nodes are indicated by bit
	# 1 in $visited.
	my $revgraph = {};
	my $visited = {};
	$self->tunit_upnodes_visit($tunits, $revgraph, $visited, $n);

	# Now visit all nodes that transitively dominate $n in the reverse
	# graph, depth-first. Visited nodes are indicated by bit 2 in
	# $visited.
	$self->tunit_upnodes_visit_reverse($tunits, $revgraph, $visited, $n);

	# The strongly connected component for $n consists of all nodes in
	# $visited that were visited in both the original graph and the
	# reverse graph. 
	my @component = grep {$visited->{$_} == 3} keys(%$visited);

	# Now merge all tunits in component
	foreach my $m (@component) {
		merge_tunit($tunits, $n, $m);
	}
}

