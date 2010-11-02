sub next_noncomment_node {
	my $graph = shift;
	my $node = max(0, shift || 0);
	my $n = shift || 1;

	# Search for next non-comment node
	my $next = undef;
	while ($node < $graph->size() && $n > 0) {
		if (! $graph->node($node)->comment()) {
			--$n;
			$next = $node if ($n == 0);
		}
		++$node;
	}

	# Return non-comment node
	return $next;
}
