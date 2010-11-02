=item $node->selected($selected) = $selected

Get/set selected lexeme at node. 

=cut

sub selected {
	my $self = shift;
	return $self->var('_selected', @_);
}
