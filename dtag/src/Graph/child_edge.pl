=item $graph->child_edge($node, $type) = [$edge, ...]

Return all child edges of node $node whose edge type equals $type.

=cut

sub child_edge {
	my $self = shift;
	my $node = shift;
	my $etype = shift;

	return [
		grep {$_->type() eq $etype} @{$self->node($node)->out()}
	];
}
