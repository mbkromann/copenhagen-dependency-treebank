=item $segment->listeners($listeners) = $listeners

Get/set list of listeners for segment.

=cut

sub listeners {
	my $self = shift;
	$self->[$SEGMENT_LISTENERS] = shift if (@_);
	return $self->[$SEGMENT_LISTENERS];
}
