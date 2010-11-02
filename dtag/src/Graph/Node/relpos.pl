=item $node->relpos($offset, $pos) = $relpos

Return relative position $relpos of node with position $pos and offset
$offset.

=cut

sub relpos {
	my $offset = shift;
	my $pos = shift;

	return $pos ? int($pos-$offset) : "";
}
