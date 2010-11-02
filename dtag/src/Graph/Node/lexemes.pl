=item $node->lexemes($lexemes) = $lexemes

Get/set list $lexemes of lexemes associated with node $node.

=cut

sub lexemes {
	my $self = shift;
    return $self->var('_lexemes', @_);
}
