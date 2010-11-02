sub node_in_autowindow {
	my ($self, $key, $node) = @_;

	# Check whether boundary exists
	my $boundary = $self->var('autoalign');
	return 1 if (! $boundary);

	# Check whether node is in range
	my ($outkey, $o1, $o2, $inkey, $i1, $i2) = @$boundary;
	if ($key eq $outkey) {
		return $o1 <= $node && $node <= $o2;
	} elsif ($key eq $inkey) {
		return $i1 <= $node && $node <= $i2;
	}

	# Return 0 by default
	return 0;
}
