=item $graph->pstep($step) = $step

Get/set step associated with graph.

=cut

sub pstep {
	my $self = shift;
	return $self->var('pstep', @_);
}
