sub tunit_is_monolingual {
	# Parameters
	my ($self, $tunits, $n) = @_;
	my $tunit = $tunits->{$n};

	# Check whether tunit contains both signs
	my $np = 0;
	foreach my $n (@$tunit) {
		if ($n > 0) {
			$np |= 1;
		} else {
			$np |= 2;
		}
	}

	# Return result
	return $np == 3 ? 0 : 1;
}

