sub subpartition {
	my $self = shift;
	my $subpartition = shift;
	my $partition = shift;
	my $subspace = $subpartition->space();
	my $space = $partition->space();

	# Check that $space is an initial subsequence of $subspace
	for (my $i = 0; $i < scalar(@$space); ++$i) {
		return 0 if ($space->[$i] ne $subspace->[$i]);
	}

	# Return 1 if successful
	return 1;
}
