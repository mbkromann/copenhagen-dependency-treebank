=item $node->input($input) = $input

Get/set node input.

=cut

sub input {
	my $self = shift;
    return $self->var('_input', @_);
}
