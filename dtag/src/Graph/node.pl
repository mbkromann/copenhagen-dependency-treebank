=item $graph->node($pos) = $node

Return node $node at node position $pos.

=cut

sub node {
	my $self = shift;
	my $i = shift;

	return (defined($i) && $i >= 0) ? $self->nodes()->[$i] : undef;
}
