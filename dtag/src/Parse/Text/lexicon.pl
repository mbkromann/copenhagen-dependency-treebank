=item $text->lexicon($lexicon) = $lexicon

Get/set default lexicon for text.

=cut

sub lexicon {
	my $self = shift;
	$self->[$TEXT_LEXICON] = shift if (@_);
	return $self->[$TEXT_LEXICON];
}
