=item $graph->lsite_auto($node) = $lsite

Return auto-generated landing site for node $node (the lowest
dominating node in the deep tree which has $node in its continuous
surface yield).

=cut


sub lsite_auto {
	my $self = shift;
	my $node = shift;
	my $lsite = $self->governor($node);

    while ($lsite && ! $self->sdominates($lsite, $node)) {
		$lsite = governor($self, $lsite);
	}
	return $lsite;
}
