=item $segment->span($span) = $span

Get/set list of links that span over $segment. ???

=cut

sub span {
	my $self = shift;
	$self->[$SEGMENT_SPAN] = shift if (@_);
	return $self->[$SEGMENT_SPAN];
}
