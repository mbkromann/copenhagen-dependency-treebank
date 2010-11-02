sub wcover2sub {
	my $self = shift;
	my $wcover = shift;
	print DTAG::Interpreter::dumper($wcover);

	# Disable numerical integration
	my $nmax = $self->nmax();
	$self->nmax(1);

	# Compute integral of $wcover
	my $cover = [map {$_->[1]} @$wcover];
	my $wcover2 = [];
	for (my $j = 0; $j <= $#$wcover; ++$j) {
		my $volume = $self->pbox_diff(sub {1}, $cover->[$j], 
			@{$j > 0 ? [@$cover[0..$j-1]] : []});
		$wcover2->[$j] = [$wcover->[$j][0] / $volume,
			$wcover->[$j][1]];
	}

	# Print $wcover
	print "WCOVER: " . join(" ", 
		map { $_->[0] . "@" . $self->print_box($_->[1])
		} @$wcover2) . "\n";

	# Re-enable numerical integration
	$self->nmax($nmax);

	# Create subroutine
	my $sub = sub {
		my $x = shift;

		# Find partition containing $x
		my $i;
		for ($i = 0; $i < $#$wcover2 
			&& ! $self->box_inside($wcover2->[$i][1], $x); ++$i) {
		};

		# Compute value in selected partition
		return $wcover2->[$i][0];
	};

	# Return subroutine
	return $sub;
}
