=item $edge->inkey($inkey) = $inkey

Get/set inkey $inkey of edge. 

=cut

sub inkey {
	my $self = shift;
	$self->[0] = shift if (@_);
	return $self->[0];
}
