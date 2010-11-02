=item $graph->next_lexeme($time) = $lexeme

Return first lexeme after time position $time.

=cut

sub next_lexeme {
	my $self = shift;
	my $time = shift;
	my $next = $time + 1;
	return $self->node($next) ? $next : undef;
}
