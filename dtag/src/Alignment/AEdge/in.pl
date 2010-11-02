=item $edge->in($in) = $in

Get/set in-nodes $in of edge. 

=cut

sub in {
	my $self = shift;
	$self->[1] = shift if (@_);
	return $self->[1];
}
