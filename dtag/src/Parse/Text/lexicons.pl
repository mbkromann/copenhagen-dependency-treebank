=item $text->lexicons($lexicons) = $lexicons

Get/set lexicon hash for this text.

=cut

sub lexicons {
	my $self = shift;
	$self->[$TEXT_LEXICONS] = shift if (@_);
	return $self->[$TEXT_LEXICONS];
}
