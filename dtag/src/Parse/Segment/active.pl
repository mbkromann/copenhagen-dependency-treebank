=item $segment->active($active) = $active

Get/set list of active lexemes starting at segment.

=cut

sub active {
	my $self = shift;
	$self->[$SEGMENT_ACTIVE] = shift if (@_);
	return $self->[$SEGMENT_ACTIVE];
}
