# split = [$mlog_post, $cover, $info, $moved]

sub compute_opt_partitioning5 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];
	my $mlogp_old = shift || 0;

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self], 0];
	my $loptsplit = $split; 
	my $optsplit = undef;
	my $maxdepth = 10;
	my $depth = 0;
	my $newcover;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth 
			&& ((! $optsplit) || $optsplit->[0] >= 0)) {
		# Increment depth
		++$depth;
		print $distribution->print_cover2("      PDEPTH $depth",
			[@$precover, @{$split->[1]}, @$postcover],
			$mlogp_old + $loptsplit->[0]) if ($depth > 1);

		# Reset best split at current depth
		$loptsplit = undef;
		my $super = $split->[1][0];

		# Find all partitions of data
		my $subdata = $distribution->hierarchy()->subdata2(
			$super->space(), $super->data(), $distribution->mindata());
	
		# Try all partitions of data to find the locally best
		foreach my $d (@$subdata) {
			# Setup child
			my $child = $super->clone();
			$child->setup($distribution, $d, $d->plane(), $super);

			# Find all observations in $super that are not in child
			my $hash = {};
			my $list = [];
			map {$hash->{$_} = 1} @{$child->data()->observations()};
			map {push @$list, $_ if (! $hash->{$_})}
				@{$super->data()->observations()};
			
			# Setup parent
			my $pdata = $super->data()->clone();
			$pdata->observations($list);
			my $parent = $super->clone();
			$parent->init($distribution, $pdata, $super->plane(), 
				$super->space());

			# Compute prior probability mass of child and parent
			$child->compute_prior_mass($distribution, $precover);
			$parent->compute_prior_mass($distribution, [@$precover, $child]);

			# Compute posterior probability of child and parent
			my $delta = $child->compute_mlog_posterior($distribution)
				+ $parent->compute_mlog_posterior($distribution) 
				- $super->mlog_posterior() + $split->[0];

			# Compute moved count
			my $moved_count = $child->count() 
				- $child->prior_mass() * $distribution->total();

			# Compute new cover
			my $cover = $split->[1];
			$newcover = [$child, $parent, @$cover[1..$#$cover]];

			# Delete parent if it is degenerate
			#print "        parent=" . $parent->count() . " moved=" .
			#	($parent->count() - $parent->prior_mass() *
			#		$distribution->total())	. "\n";
			if ($parent->count() < $distribution->mindata() ||
				$parent->count() - $parent->prior_mass() *
					$distribution->total()) {
				my $merged = $distribution->merge($newcover, 1);
				if ($merged && $merged->[1]) {
					$delta = $merged->[0] - $super->mlog_posterior();
					$newcover = $merged->[1];
				}
			} 

			# Debug
			print $distribution->print_cover2("      split",
				[@$precover, @$newcover, @$postcover],
				$delta + $mlogp_old, $moved_count);

			# If $delta is smaller than $opt_delta, then new partitioning
			# is currently optimal
			if ((! $loptsplit) || (! $loptsplit->[1])
				|| ($moved_count >= 0 && $loptsplit->[2] < 0)
				|| ($delta < $loptsplit->[0] 
					&& ! ($moved_count < 0 && $loptsplit->[2] > 0))) {
				$loptsplit = [$delta, $newcover, $moved_count];
			}
		}

		# Debug
		#print "optsplit=" . DTAG::Interpreter::dumper($optsplit) . "\n";
		#print "loptsplit=" . DTAG::Interpreter::dumper($loptsplit) . "\n";
	
		# Use locally optimal split as new split, and as globally
		# optimal split if it is better than old globally optimal split
		$split = $loptsplit;
		if ($loptsplit && ((! $optsplit) 
			|| ($loptsplit->[2] >= 0 && $optsplit->[2] < 0)
			|| ($loptsplit->[0] < $optsplit->[0]
				&& ! ($loptsplit->[2] < 0 && $optsplit->[2] > 0)))) {
			$optsplit = $loptsplit;
		}
	}

	# Return optimal partitioning
	return $optsplit 
		? [$optsplit->[0], [@$precover, @{$optsplit->[1]}, @$postcover],
			$optsplit->[2]]
		: undef;
}
