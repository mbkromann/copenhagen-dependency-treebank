=item $node->type($type) = $type

Get/set node type.

=cut

sub type {
	my $self = shift;
    return $self->var('_type', @_);
}
