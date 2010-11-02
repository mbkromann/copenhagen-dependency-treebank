=item $graph->lsite($node) = $lsite

Return landing site for node $node.

=cut

sub lsite {
	my $self = shift;
	my $node = shift;
	my @surf = @{$self->etypes()->{'surf'}};

	# Find governor and landing site edges
	my $lsite;
	foreach my $e (@{$self->node($node)->in()}) {
		if (grep {$e->type() eq $_} @surf) {
			return $e->out();
		}
	}

	# No landing site found: return governor
	return undef;
}
