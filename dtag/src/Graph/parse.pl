=item $graph->parse($parse) = $parse

Get/set parse object associated with graph.

=cut

sub parse {
	my $self = shift;
	$self->{'parse'} = shift if (@_);
	return $self->{'parse'};
}
