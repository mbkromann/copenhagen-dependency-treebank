=item $graph->size() = $size

Return the number of nodes in the graph.

=cut

sub size {
	my $self = shift;
	return scalar(@{$self->nodes()});
}
