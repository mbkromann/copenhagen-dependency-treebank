=item $node->comment($comment) = $comment

Get/set comment status of node: 1 = comment, 0 = not comment.

=cut

sub comment {
	my $self = shift;
	$self->type(undef) if (@_);
	return $self->var('_comment', @_);
}
	
