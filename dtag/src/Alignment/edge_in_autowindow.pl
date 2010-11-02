sub edge_in_autowindow {
	my ($self, $edge) = @_;

	# Check whether boundary exists
	my $boundary = $self->var('autoalign');
	return 1 if (! $boundary);

	# Check whether edge is in range
	my ($outkey, $o1, $o2, $inkey, $i1, $i2) = @$boundary;
	my $ein = $edge->inArray();
	my $eout = $edge->outArray();
	my $imin = $ein->[0];
	my $imax = $ein->[$#$ein];
	my $omin = $eout->[0];
	my $omax = $eout->[$#$eout];

	return 
		($edge->inkey() ne $inkey ||
			($edge->inkey() eq $inkey && $i1 <= $imin && $imax <=
			$i2))
		&& ($edge->outkey() ne $outkey ||
			($edge->outkey() eq $outkey && $o1 <= $omin && $omax <= $o2));

	# Return 0 by default
	return 0;
}
