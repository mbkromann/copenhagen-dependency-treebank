=item $graph->parent($node, $etype) = $nodes

Return list $nodes of all parent nodes for node $node with edge type
$etype.

=cut


sub parent {
	my $self = shift;
	my $node = shift;
	my $etype = shift;

	return [
		map {$_->out()} 
			grep {$_->type() eq $etype} @{$self->node($node)->in()}
	];
}
