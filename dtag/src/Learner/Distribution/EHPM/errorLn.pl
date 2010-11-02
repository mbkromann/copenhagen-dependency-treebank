sub errorLn {
	my $self = shift;
	my $cover = shift;
	my $true = shift;
	my $exp = shift || 2;

	# Compute Ln error norm for estimate given by $cover for $true
	my $n = 100;
	my $sum = 0;
	for (my $i = 0.5; $i < $n; ++$i) {
		for (my $j = 0.5; $j < $n; ++$j) {
			my $x = [$i / $n, $j / $n];
			my $truevalue = &$true($x);
			my $estvalue = $self->f($x, $cover);
			$sum += abs($truevalue-$estvalue) ** $exp;
		}
	}

	# Return Ln norm
	return ($sum / ($n * $n))  ** (1 / $exp);
}
