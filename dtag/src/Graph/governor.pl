=item $graph->governor($node) = $gov

Return governor $gov for node $node.

=cut

sub governor {
	my $self = shift;
	my $node = shift;

	# Find governor and landing site edges
	my $governor;
	foreach my $e (@{$self->node($node)->in()}) {
		if ($self->is_dependent($e)) {
			return $e->out();
		}
	}

	# No governor found
	return undef;
}


