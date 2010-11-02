sub disparity {
	my $self = shift;
	my $gtest = shift;

	# Calculate test value
	my $rho = 0;
	while (@_) {
		my $p = shift;
		my $pi = shift;
		$rho += &$gtest($p / $pi - 1) * $pi;
	}

	# Return test value
	return $rho;
}

