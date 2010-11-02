=item $node->active($active) = $active

Get/set list $active of active lexemes associated with node $node. 

=cut

sub active {
	my $self = shift;
	return $self->var('_active', @_);
}
