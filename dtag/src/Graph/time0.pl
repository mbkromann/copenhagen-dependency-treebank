=item $graph->time0($node) = $time0

Return starting time of node $node.

=cut

sub time0 {
	my $self = shift;
	my $node = shift;

	# Find node object
	my $nodeobj = $self->node($node);
	return undef if (! $nodeobj);

	# Find node object's time0
	my $time0 = $nodeobj ? $nodeobj->time0() : undef;
	return defined($time0) ? $time0 : $node;
}
