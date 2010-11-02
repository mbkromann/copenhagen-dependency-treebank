=item $lexeme->input($input) = $input

Get/set input associated with lexeme.

=cut

sub input {
	my $self = shift;
	$self->[$LEXEME_INPUT] = shift if (@_);
	return $self->[$LEXEME_INPUT];
}
