=item $graph->position($pos) = $pos

Get/set position of graph. ???

=cut

sub position {
	my $self = shift;
	return $self->var('position', @_);
}
