=item $graph->edge_del($edge) = $edge

Remove edge $edge from $graph.

=cut

sub edge_del {
	my $graph = shift;
	my $edge = shift;
	my $nin  = $graph->node($edge->in());
	my $nout = $graph->node($edge->out());

	# Delete edge in in-node
	my $ein = $nin->in();
	for (my $i = 0; $i < scalar(@$ein); ) {
		if ($ein->[$i] == $edge) {
			splice(@$ein, $i, 1);
		} else {
			++ $i;
		}
	}

	# Delete edge in out-node
	my $eout = $nout->out();
	for (my $i = 0; $i < scalar(@$eout); ) {
		if ($eout->[$i] == $edge) {
			splice(@$eout, $i, 1);
		} else {
			++ $i;
		}
	}

	# Return edge
	return $edge;
}
