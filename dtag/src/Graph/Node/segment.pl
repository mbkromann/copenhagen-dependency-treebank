=item $node->segment($segment) = $segment

Get/set list of segments associated with node.

=cut

sub segment {
	my $self = shift;
	return $self->var('_segment', @_);
}
