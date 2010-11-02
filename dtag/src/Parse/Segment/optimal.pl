=item $segment->optimal($optimal) = $optimal

Get/set optimal lexeme associated with segment.

=cut

sub optimal {
	my $self = shift;
	$self->[$SEGMENT_OPTIMAL] = shift if (@_);
	return $self->[$SEGMENT_OPTIMAL];
}
