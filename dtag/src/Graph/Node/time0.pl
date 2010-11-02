=item $node->time0($time0) = $time0

Get/set starting time at node.

=cut


sub time0 {
	my $self = shift;
	return $self->var('time0', @_) || undef;
}
