=item $graph->offset($offset) = $offset

Get/set offset associated with graph (number for first line of file).

=cut

sub offset {
	my $self = shift;
	return $self->var('_offset', @_) || 0;
}
