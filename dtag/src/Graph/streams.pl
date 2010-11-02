=item $graph->streams($time1, $time2) = $streams

Return a list of stream identifiers for all streams that are active
between times $time1 and $time2 (which default to the beginning and
end of the graph, if unspecified).

=cut

sub streams {
	my $self = shift;
	my $time1 = shift || 0;
	my $time2 = shift || $self->size();
	my $streams = {};

	# Examine all nodes for streams
	for (my $i = $time1; $i < $time2; ++$i) {
		my $node = $self->node($i);
		my $stream = $node ? $node->stream() : undef;
		$streams->{$stream} = 1 if ($stream);
	}

	# Return streams
	return [sort(keys(%$streams))];
}
