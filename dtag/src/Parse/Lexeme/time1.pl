=item $lexeme->time1($time1) = $time1

Get/set ending time of lexeme.

=cut

sub time1 {
	my $self = shift;
	$self->[$LEXEME_TIME1] = shift if (@_);
	return $self->[$LEXEME_TIME1];
}

