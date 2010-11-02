=item $edge->in($in) = $in

Get/set in-node $in of edge. 

=cut

sub in {
	my $self = shift;
	$self->[0] = shift if (@_);
	return $self->[0];
}
