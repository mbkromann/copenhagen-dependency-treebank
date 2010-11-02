=item $graph->nodes($nodes) = $nodes

Get/set node list $nodes.

=cut

sub nodes {
	my $self = shift;
	return $self->var('nodes', @_);
}
