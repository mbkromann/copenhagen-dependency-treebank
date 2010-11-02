=item $segment->time0($time0) = $time0

Get/set starting time of segment.

=cut

sub time0 {
	my $self = shift;
	$self->[$SEGMENT_TIME0] = shift if (@_);
	return $self->[$SEGMENT_TIME0];
}

