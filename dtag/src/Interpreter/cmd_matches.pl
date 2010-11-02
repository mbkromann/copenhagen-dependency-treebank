sub cmd_matches {
	my $self = shift;
	my $cmd = shift;

	# Process options
	my $options = {};
	my @stats = ();
	my $sort = 1;
	while ($cmd) {
		if ($cmd =~ s/^-nomatch//) {
			$options->{'nomatch'} = 1;
		} elsif ($cmd =~ s/^-nokey//) {
			$options->{'nokey'} = 1;
		} elsif ($cmd =~ s/^-notext//) {
			$options->{'notext'} = 1;
		} elsif ($cmd =~ s/^-stats\(\s*(key|text)\s*\)//) {
			@stats = ($1);
		} elsif ($cmd =~ s/^-stats\(\s*(key|text)\s*,\s*(key|text)\)//) {
			@stats = ($1, $2);
		} elsif ($cmd =~ s/^-a(lpha)?//) {
			$sort = ($sort > 0) ? 1 : -1;
		} elsif ($cmd =~ s/^-n(um)?//) {
			$sort = ($sort > 0) ? 2 : -2;
		} elsif ($cmd =~ s/^-r(everse)?//) {
			$sort = - $sort;
		} elsif ($cmd =~ s/^-p(rint)?(=([0-9]+))?//) {
			$options->{'print'} = (defined($3) ? $3 : 20);
		} else {
			$cmd =~ s/^.//;
		}
	}

	# Print all matches or all statistics
	my $matches = $self->{'matches'};
	my $sorthash = {};
	my $count = {};
	my ($key1, $key2, $list, $hash);
	my $i = 0;
	foreach my $f (sort(keys(%$matches))) {
		foreach my $m (@{$matches->{$f}}) {
			++$i;
			if (! @stats) {
				# Print match
				if (defined($options->{'print'})) {
					my $window = $options->{'print'};
					my $i1 = 1e30;
					my $i2 = -1e30;
				    my @vars = sort(grep {substr($_, 0, 1) eq '$'} keys(%$m));
					map {
						my $v = $m->{$_}; 
						$i1 = $v if ($v < $i1); 
						$i2 = $v if ($v > $i2)
					} @vars;
					$self->goto_match($i);
					print "\n\t" . $self->graph()->words($i1 - $window, $i2 +
						$window, " ") . "\n\n"; 
				} else {
					print $self->print_match($i, $f, $m, $options);
				}
			} else {
				# Sort matches
				$key1 = $m->{$stats[0]} || "";

				# Find array stored in sorted hash
				if (scalar(@stats) == 1) {
					$list = $sorthash->{$key1} 
						= ($sorthash->{$key1} || []);
				} else {
					$key2 = $m->{$stats[1]} || "";
					$list = $sorthash->{$key1}{$key2} 
						= ($sorthash->{$key1}{$key2} || []);
				}

				# Push current match onto list
				++$count->{$key1};
				push @$list, $i;
			}

			# Abort if requested
			return 1 if ($self->abort());
		}
	}

	# Print statistics
	if (@stats) {
		# Define sorting and count subroutines
		my $cntsub1 = sub {
			my $hash = shift; my $count = shift; my $key = shift; 
			return $count->{$key} || 0; 
		};
		my $cntsub2 = sub {
			my $hash = shift; my $count = shift; my $key = shift; 
			return scalar(@{$hash->{$key}});
		};

		# Sorting procedure
		sub sort_hash {
			my $hash = shift;
			my $count = shift;
			my $sort = shift; # 1/-1=alpha, 2/-2=num, -1,-2=reverse
			my $cntsub = shift;

			# Sort hash
			my @sorted;
			if (abs($sort) == 1) {
				@sorted = sort { $a cmp $b } 
					keys(%$hash);
			} else {
				@sorted = sort { &$cntsub($hash, $count, $a) 
						<=> &$cntsub($hash, $count, $b) || $a cmp $b }
					keys(%$hash);
			}

			# Reverse list, if required
			return ($sort < 0) ? reverse(@sorted) : @sorted;
		}

		# Print all primary and secondary keys
		foreach $key1 (sort_hash($sorthash, $count, $sort, $cntsub1)) {
			printf '%4d: %s' . "\n", $count->{$key1}, $key1;

			if (scalar(@stats) == 1) {
				# One key
				print " " x 6 . "M" . join(" M", @{$sorthash->{$key1}}) . "\n"
					if (! $options->{'nomatch'});
			} else {
				# Two keys
				#foreach $key2 (keys(%{$sorthash->{$key1}})) {
				foreach $key2 (sort_hash($sorthash->{$key1}, $count, 
						$sort, $cntsub2)) {
					$list = $sorthash->{$key1}{$key2};
					printf '%8d: %s' . "\n", scalar(@$list), $key2;
					print " " x 10 . "M" . join(" M", @$list) . "\n"
						if (! $options->{'nomatch'});
				}
			}
		}
	}

	# Return
	return 1;
}


