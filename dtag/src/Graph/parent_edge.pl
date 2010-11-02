=item $graph->parent_edge($node, $etype) = $edges

Return list $edges of all parent edges for node $node with edge type
$etype.

=cut

sub parent_edge {
	my $self = shift;
	my $node = shift;
	my $etype = shift;

	return [
		grep {$_->type() eq $etype} @{$self->node($node)->in()}
	];
}
