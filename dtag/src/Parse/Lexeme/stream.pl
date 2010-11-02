=item $lexeme->stream($stream) = $stream

Get/set lexeme stream variable.

=cut

sub stream {
	my $self = shift;
	$self->[$LEXEME_STREAM] = shift if (@_);
	return $self->[$LEXEME_STREAM];
}
