sub cmd_parse2dtag {
	my $self = shift;
	my $ifile = shift;
	my $ofile = shift;

	# Open input file
	open("SCRIPT", "< $ifile")
		|| return error("cannot open file for reading: $ifile");
	
	# Read script file line by line, and add to "line"
	my $n = 0;
	my $step = 0;
	my $lines = [];
	my $steps_hash = {};
	my $lines_hash = {};
	my $multi = 0;
	while (my $line = <SCRIPT>) {
		if ($line =~ /^\s*multi\s+([0-9]+)\s*$/) {
			++$step;
			$multi = $1;
		} elsif ($line =~ /^\s*(edge\s+)?([0-9]+)\s+(\S+)\s+([0-9]+)\s*$/) {
			# Edge addition
			if ($multi > 0) {
				--$multi;
			} else {
				++$step;
			}
			push @$lines, ["edge", $2, $3 . ":$step", $4, "\n"];
			$lines_hash->{"$2 $3 $4"} = $#$lines;
			$steps_hash->{"$2 $3 $4"} = $step;
		} elsif ($line =~ /^\s*del\s+([0-9]+)\s+(\S+)\s+([0-9]+)\s*$/) {
			# Edge deletion
			if ($multi > 0) {
				--$multi;
			} else {
				++$step;
			}
			my $edgeline = $lines_hash->{"$1 $2 $3"};
			my $edgestep = $steps_hash->{"$1 $2 $3"};
			push @$lines, ["# undo " . ($step || "?") . ":", $line];
			if ($edgeline) {
				$lines->[$edgeline][2] .= "-$step";
			}
		} else {
			push @$lines, [$line];
		}

		# Increment line counter
		++$n;
	}

	# Close input
	close("SCRIPT");

	# Print output
	open("SCRIPT", "> $ofile")
		|| return error("cannot open file for writing: $ofile");
	foreach my $line (@$lines) {
		print SCRIPT join(" ", @$line);
	}
	close("SCRIPT");
	
	# Return
	return 1;
}
