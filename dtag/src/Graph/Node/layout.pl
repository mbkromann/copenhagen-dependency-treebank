=item $node->layout($layout) = $layout

Get/set node layout.

=cut

sub layout {
	my $self = shift;
    return $self->var('_layout', @_);
}
