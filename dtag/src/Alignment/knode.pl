=item $alignment->knode($key, $pos) = $node

Return node $node at node position $pos with key $key.

=cut

sub knode {
	my $self = shift;
	my $key = shift;
	my $i = shift;
	my $graph = $self->graph($key);
	return defined($graph) ? $graph->knode("", $i) : undef;
}
