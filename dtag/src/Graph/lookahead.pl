=item $graph->lookahead($lookahead) = $lookahead

Get/set lookahead associated with graph.

=cut

sub lookahead {
	my $self = shift;
	$self->{'lookahead'} = shift if (@_);
	return $self->{'lookahead'} || $DEFAULT_LOOKAHEAD;
}
