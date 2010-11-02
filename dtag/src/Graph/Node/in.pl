=item $node->in($in) = $in

Get/set list $in of in-edges for node $node.

=cut

sub in {
	my $self = shift;
	return $self->var('_in', @_);
}
