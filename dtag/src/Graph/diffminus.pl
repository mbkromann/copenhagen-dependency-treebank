=item $graph->diffminus($edge) = $boolean

Return true if $edge is a diff-edge which does not exist in $graph,
otherwise return false. 

=cut

sub diffminus {
	my $self = shift;
	my $edge = shift;
	my $unlabelled = shift;

	# Minus edges are always diff edges
	return 0 if (! $edge->var('diff'));

	# Minus edges must not exist as non-diff edges
	return (grep {(! $_->var('diff')) && $edge->eq($_, $unlabelled)} 
		@{$self->node($edge->in())->in()}) ?  0 : 1;
}
