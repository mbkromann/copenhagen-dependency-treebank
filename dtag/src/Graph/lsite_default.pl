=item $graph->lsite_default($node) = $lsite

Return default landing site for node $node (defined as the parent
node with edge type "land", or, if no such node exists, the governor
of $node). 

=cut

sub lsite_default {
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
	return $self->governor($node);
}
