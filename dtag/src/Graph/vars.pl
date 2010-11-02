=item $graph->vars($vars) = $vars

Get/set list $vars of user-defined variable names in graph.

=cut

sub vars {
	my $self = shift;
	return $self->var('vars', @_);
}
