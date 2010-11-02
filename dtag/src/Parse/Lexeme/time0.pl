=item $lexeme->time0($time0) = $time0

Get/set starting time of lexeme. 

=cut

sub time0 {
	my $self = shift;
	$self->[$LEXEME_TIME0] = shift if (@_);
	return $self->[$LEXEME_TIME0];
}

