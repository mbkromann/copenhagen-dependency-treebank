=item $graph->govedge($node) = $gov

Return governor edge for node $node.

=cut

sub govedge {
	my $self = shift;
	my $node = shift;

	# Find governor edge
	foreach my $e (@{$node->in()}) {
		if ($self->is_dependent($e)) {
			return $e;
		}
	}

	# No governor found
	return undef;
}


