=item $graph->child($node, $type) = [$child1, $child2, ...]

Return list of all child nodes of node $node which are connected to 
$node by an edge with type $type.

=cut


sub child {
	my $self = shift;
	my $node = shift;
	my $etype = shift;

	return [
		map {$_->in()} 
			grep {$_->type() eq $etype} @{$self->node($node)->out()}
	];
}
