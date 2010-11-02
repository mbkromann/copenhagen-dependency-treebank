sub subdivisions {
	my $self = shift;
	my $planes = shift;

	# Calculate box corresponding to planes
	my $box = $self->space2box($planes);
	return [] if (! defined($box));

	# Find subdivisions of box
	my $dim = $self->dimension();
	my $branching = $self->branching();
	my $subdivisions = [];
	for (my $i = 1; $i <= $dim; ++$i) {
		# Process each dimension
		my $range = $box->[$i-1];
		my $min = $range->[0];
		my $max = $range->[1];
		my $increment = ($max - $min) / $branching;

		# Split interval into $branching equisized intervals
		for (my $j = 1; $j <= $branching; ++$j) {
			push @$subdivisions, [$i, $min, $min + $increment];
			$min += $increment;
		}
	}

	# Return subdivisions
	return $subdivisions;
}
