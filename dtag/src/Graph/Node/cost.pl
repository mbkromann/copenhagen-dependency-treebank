=item $node->cost($cost) = $cost

Get/set cost associated with node.

=cut

sub cost {
	my $self = shift;
	return $self->var('_cost', @_);
}
