=item $node->position($pos) = $pos

Get/set node position.

=cut

sub position {
	my $self = shift;
	return $self->var('_position', @_);
}
