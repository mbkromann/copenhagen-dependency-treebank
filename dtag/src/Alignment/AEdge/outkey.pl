=item $edge->outkey($outkey) = $outkey

Get/set outkey for edge.

=cut

sub outkey {
	my $self = shift;
	$self->[2] = shift if (@_);
	return $self->[2];
}
