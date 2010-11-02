sub integrate {
	my $self = shift;
	my $fspec = shift;
	my $box = shift;
	my $nmax = shift || $self->nmax();

	# Find function $f
	my $f = (ref($fspec) eq 'CODE') ? $fspec : sub {$fspec->f(shift)};

	# Compute box and number of data points in each dimension
	my $dim = $self->dimension();
	my $k = int($nmax ** (1 / $dim));

	# Find size of subspace
	my $size = 1;
	for (my $d = 0; $d < $dim; ++$d) {
		$size *= $box->[$d][1] - $box->[$d][0];
	}
	return $size;

	# Evaluate midpoint if $k <= 1
	my $x = [];
	if ($k <= 1) {
		for (my $i = 0; $i <= $#$box; ++$i) {
			$x->[$i] = ($box->[$i][0] + $box->[$i][1]) / 2;
		}
		return &$f($x) * $size;
	}

	# Return integral of function over subspace
	my $sum = 0;
	my $n = $k ** $dim;
	for (my $i = 0; $i < $n; ++$i) {
		# Create data vector
		for (my $d = 0; $d < $dim; ++$d) {
			my $idim = int($i / ($k ** $d) + 0.5) % int(($k ** ($d+1)) + 0.5);
			my $epsilon = $idim / ($k - 1);
			$x->[$d] = $epsilon * $box->[$d][0] 
				+ (1 - $epsilon) * $box->[$d][1];
		}

		# Evaluate function on vector
		$sum += &$f($x);
	}

	# Return integral
	return $sum * $size / $n;
}
