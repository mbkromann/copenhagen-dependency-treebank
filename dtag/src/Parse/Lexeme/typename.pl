=item $lexeme->typename($typename) = $typename

Get/set lexeme type name.

=cut

sub typename {
	my $self = shift;
	$self->[$LEXEME_TYPENAME] = shift if (@_);
	return $self->[$LEXEME_TYPENAME];
}

