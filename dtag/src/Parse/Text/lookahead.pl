=item $text->lookahead($lookahead) = $lookahead

Get/set lookahead for text.

=cut

sub lookahead {
	my $self = shift;
	$LOOKAHEAD = shift || 1 if (@_);
	return $LOOKAHEAD;
}
