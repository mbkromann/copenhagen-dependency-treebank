=item $node->stream($stream) = $stream

Get/set stream associated with node (default stream = 0).

=cut

sub stream {
	my $self = shift;
	return $self->var('stream', @_) || 0;
}
