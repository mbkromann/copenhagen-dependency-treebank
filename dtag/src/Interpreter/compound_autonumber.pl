sub compound_autonumber {
	my $compound = shift;
	$compound = "" if (! defined($compound));
	$compound = decode_utf8($compound);

	# Counter characters
	my $odigit = "^";
	my $ldigits = ["¹", "²", "³", "⁰"];
	my $digits = join("", @$ldigits) . $odigit;

	# Insert spaces before all segment identifiers
	$compound =~ s/([^$digits\|])([$digits]+)/$1\|$2/g;

	# Split compound into segments
	my @segments = split(/\|/, $compound);

	# Compute identifier for each segment
	my @ids = ();
	for (my $i = 0; $i <= $#segments; ++$i) {
		if ($segments[$i] =~ /^([$digits]+)/) {
			$ids[$i] = $1 || "";
		} else {
			$ids[$i] = "";
		}
	}

	# Process compound string
	if (! $ids[0]) {
		# Compound does not have any identifiers: renumber segments
		if (scalar(@segments) > 1) {
			$compound = "";
			for (my $i = 0; $i <= $#segments; ++$i) {
				$compound .= ($odigit x int($i / 3)) 
					. $ldigits->[$i % 3] . $segments[$i];
			}
		}
	} else {
		# Compound already contains identifiers: split identifiers
		my $prefix = "";
		my $count = 0;
		for (my $i = 0; $i <= $#segments; ++$i) {
			if ($ids[$i]) {
				# Segment is numbered: split numbering if next
				# segment is unnumbered; otherwise unchanged
				$prefix = $ids[$i];
				$count = 0;
				if ($i < $#segments && (! $ids[$i + 1])) {
					$segments[$i] =~ s/[$digits]//g;
					$segments[$i] = $prefix . $ldigits->[0] . $segments[$i];
					++$count;
				}
			} else {
				# Segment is unnumbered: add number to prefix
				$segments[$i] = $prefix . ("$odigit" x int($count / 3)) 
					. $ldigits->[$count % 3] . $segments[$i];
				++$count;
			}
		}
		$compound = join("", @segments);
	}
	
	return encode_utf8($compound);
}
