sub ps_dist {
	my $self = shift;
	my $f = shift || sub {$self->f(@_)};

	# Parameters
	my $n = 100;
	my $exp = 2;
	my $mingray = 0.2;
	my $maxdist = log(100) / log(2);

	# Find maximum value of distribution
	my $max = 0;
	for (my $i = 0.5; $i < $n; ++$i) {
		for (my $j = 0.5; $j < $n; ++$j) {
			my $value = &$f([$i / $n, $j / $n]) || 0;
			$max = $value if ($value > $max);
		}
	}

	# Print values
	my $s = "% Print distribution\ngsave\n";
	for (my $i = 0.5; $i < $n; ++$i) {
		for (my $j = 0.5; $j < $n; ++$j) {
			my $value = &$f([$i / $n, $j / $n]) || 1e-100;
			# my $dist = - log($value / $max) / log($exp);
			# my $epsilon = min($maxdist, $dist) / $maxdist;
			# my $gray = sprintf("%.2g", $epsilon + (1-$epsilon) * $mingray);
			my $gray = sprintf("%.2g", 1 - ($value / $max) * (1 - $mingray));

			# Print box
			$s .= 
				"$gray setgray "
				. (($i - 0.5) / $n * 100) . " " . (($j - 0.5) / $n * 100) . " " 
				. (($i+0.5) / $n * 100) . " " . (($j + 0.5) / $n * 100) . " box gsave stroke grestore fill\n";
		}
	}

	
	# Return string
	return $s . "grestore\n0 setgray 0 0 100 100 box stroke\n\n";
}

