=item $text->next_lexeme($time) = $next

Return starting time for next lexeme after time $time.

=cut

sub next_lexeme {
	my $self = shift;
	my $time = shift;
	my $next = $time + 1;
	return ($next >= $self->time1()) ? $next : undef;
}
