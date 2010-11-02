=item $graph->time1($node) = $time1

Return ending time of node $node.

=cut

sub time1 {
	my $self = shift;
	my $node = shift;

	# Find node object
	my $nodeobj = $self->node($node);
	return undef if (! $nodeobj);

	# Find node object's time1
	my $time1 = $nodeobj ? $nodeobj->time1() : undef;
	return defined($time1) ? $time1 : $node + 1;
}
