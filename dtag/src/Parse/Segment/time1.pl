=item $segment->time1($time1) = $time1

Get/set ending time of segment.

=cut

sub time1 {
	my $self = shift;
	$self->[$SEGMENT_TIME1] = shift if (@_);
	return $self->[$SEGMENT_TIME1];
}

