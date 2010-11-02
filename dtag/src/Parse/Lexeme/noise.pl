=item $lexeme->noise($noise) = $noise

Get/set lexeme noise variable.

=cut

sub noise {
	my $self = shift;
	$self->[$LEXEME_NOISE] = shift if (@_);
	return $self->[$LEXEME_NOISE];
}

