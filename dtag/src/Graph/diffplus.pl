=item $graph->diffplus($edge) = $boolean

Return true if $edge is a non-diff edge which does not exist in the
associated diff $graph, otherwise return false. 

=cut

sub diffplus {
	my $self = shift;
	my $edge = shift;

	# Plus edges are always non-diff edges
	return 0 if ($edge->var('diff'));

	# Plus edges must not exist as diff edges
	return (grep {$_->var('diff') && $edge->eq($_)} 
		@{$self->node($edge->in())->in()}) ?  0 : 1;
}
