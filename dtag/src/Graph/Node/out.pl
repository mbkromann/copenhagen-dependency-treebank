=item $node->out($out) = $out

Get/set list $out of out-edges at node $node.

=cut

sub out {
	my $self = shift;
	return $self->var('_out', @_);
}
