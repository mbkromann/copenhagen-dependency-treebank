=item $segment->typename($typename) = $typename

Get/set segment type name.

=cut

sub typename {
	my $self = shift;
	$self->[$SEGMENT_TYPENAME] = shift if (@_);
	return $self->[$SEGMENT_TYPENAME];
}

