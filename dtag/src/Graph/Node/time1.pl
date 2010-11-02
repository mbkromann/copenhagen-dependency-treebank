=item $node->time1($time1) = $time1

Get/set ending time at node $node.

=cut


sub time1 {
	my $self = shift;
	return $self->var('time1', @_) || undef;
}
