=item $edge->cost($cost) = $cost

Get/set edge cost.

=cut

sub cost {
	my $self = shift;
	$self->[3] = shift if (@_);
	return $self->[3];
}
