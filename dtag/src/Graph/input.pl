=item $graph->input($input) = $input

Get/set input associated with graph.

=cut

sub input {
	my $self = shift;
	return $self->var('input', @_);
}
