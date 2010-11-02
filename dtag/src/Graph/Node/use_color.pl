=item $node->use_color($color) = $color

Get/set color used at $node. ???

=cut

sub use_color {
	my $self = shift;
	$color = shift if (@_);
	return $color;
}
