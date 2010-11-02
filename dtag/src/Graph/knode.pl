=item $graph->knode($key, $pos) = $node

Return node $node at node position $pos with key $key.

=cut

sub knode {
	my $self = shift;
	my $key = shift;
	my $i = shift;

	return (defined($i) && $i >= 0 && $key eq "") 
		? $self->nodes()->[$i] 
		: undef;
}
