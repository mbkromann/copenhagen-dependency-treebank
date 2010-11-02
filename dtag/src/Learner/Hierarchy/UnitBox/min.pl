=item min($a, $b) = $min

Return the minimum of $a and $b.

=cut

sub min {
	return ($_[0] < $_[1]) ? $_[0] : $_[1];
}
