=item $lexeme->type($type) = $type

Get/set lexeme type object.

=cut

sub type {
	my $self = shift;
	$self->[$LEXEME_TYPE] = shift if (@_);
	return $self->[$LEXEME_TYPE];
}

