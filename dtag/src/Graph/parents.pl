=item $graph->parents($node) = [$governor, $lsite]

Return governor and landing site for node $node.

=cut

sub parents {
	my $self = shift;
	my $node = shift;

	# Find governor and landing site edges
	my $lsite;
	my $governor;
	foreach my $e (@{$self->node($node)->in()}) {
		if ($self->is_dependent($e)) {
			$governor = $e->out();
		}
		if ($self->is_landing($e)) {
			$lsite = $e->out();
		}
	}

	# Set landing site to governor, if undefined
	$lsite = $governor if (! defined($lsite));

	# Return governor and landing site
	return [$governor, $lsite];
}
