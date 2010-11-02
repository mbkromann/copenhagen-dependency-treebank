=item $segment->lexemes($lexemes) = $lexemes

Get/set list of lexemes starting at segment.

=cut

sub lexemes {
	my $self = shift;
	$self->[$SEGMENT_LEXEMES] = shift if (@_);
	return $self->[$SEGMENT_LEXEMES];
}
