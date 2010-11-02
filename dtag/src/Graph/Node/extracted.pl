=item $node->extracted($extracted) = $extracted

Get/set list of extractions though $node.

=cut

sub extracted {
	my $self = shift;
    return $self->var('_extracted', @_);
}
