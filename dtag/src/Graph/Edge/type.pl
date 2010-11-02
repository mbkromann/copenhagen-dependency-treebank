=item $edge->type($type) = $type

Get/set edge type.

=cut

sub type {
	my $self = shift;
	$self->[2] = shift if (@_);
	return $self->[2];
}
