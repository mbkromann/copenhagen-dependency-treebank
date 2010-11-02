sub merge_tunit {
	my ($tunits, $n1, $n2) = @_;

	# Get tunits to merge
	my $tunit1 = $tunits->{$n1};
	my $tunit2 = $tunits->{$n2};

	# Initialize with default value if undefined
	$tunit1 = $tunits->{$n1} = [$n1] if (! defined $tunit1);
	$tunit2 = $tunits->{$n2} = [$n2] if (! defined $tunit2);

	# Return empty list if the two nodes have been merged already
	return() if ($tunit1 eq $tunit2 || $n1 == $n2);

	# Compute dead tunits
	my @dead = (tunit2str($tunit1), tunit2str($tunit2));

	# Ensure tunit1 has more elements than tunit2 by swapping, if necessary
	if ($#$tunit1 < $#$tunit2) {
		$tunit1 = $tunit2;
		$tunit2 = $tunits->{$n1};
	}

	# Append $tunit2 to $tunit1
	push @$tunit1, @$tunit2;

	# Change all references from tunit2 to tunit1
	foreach my $n (@$tunit2) {
		$tunits->{$n} = $tunit1;
	}

	# Debug
	if ($debug) {
		print "    merged ", join(" ", 
			map {int2str($_)} @$tunit1), 
			"\n";
	}

	# Return 1
	return @dead;
}

