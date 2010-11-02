=item $edge->out($out) = $out

Get/set out-node for edge.

=cut

sub out {
	my $self = shift;
	$self->[1] = shift if (@_);
	return $self->[1];
}
