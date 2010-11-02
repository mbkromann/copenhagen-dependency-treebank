=item max($a, $b) = $max

Return the maximum of $a and $b.

=cut

sub max {
	return ($_[0] > $_[1]) ? $_[0] : $_[1];
}
