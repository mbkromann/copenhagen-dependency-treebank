sub compute_opt_partitioning3 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self], 0];
	my $optsplit = $split;
	my $loptsplit = $split; 
	my $maxdepth = 20;
	my $depth = 0;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth && $optsplit->[0] >= 0) {
		# Increment depth
		++$depth;
		print "    DEPTH $depth at " 
			. $distribution->print_cover([@$precover, @{$split->[1]},
				@$postcover])
			. "\n" if ($depth > 1);

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

			# Debug
			my $cover = $split->[1];
			print "    " 
            	. sprintf("%8s", sprintf("% 6g", $delta))
            	. sprintf("%8s", sprintf("% 6g", $moved_count))
				. " split " 
				. $distribution->print_cover([@$precover, $child, $parent, 
					@$cover[1..$#$cover], @$postcover])
				. "\n";

			# If $delta is smaller than $opt_delta, then new partitioning
			# is currently optimal
			if ((! defined($loptsplit)) || $delta < 0
				&& $loptsplit->[2] < $moved_count) {
				$loptsplit = [$delta, [$child, $parent, 
					@$cover[1..$#$cover]], $moved_count];
			}
		}

		# Use locally optimal split as new split, and as globally
		# optimal split if it is better than old globally optimal split
		$split = $loptsplit;
		if ($loptsplit && $loptsplit->[0] < 0 
				&& $loptsplit->[2] > $optsplit->[2]) {
			$optsplit = $loptsplit;
		}
	}

	# Set optimal delta and partitioning
	if ($optsplit->[0] < 0) {
		return [$optsplit->[0], [@$precover, @{$optsplit->[1]}, @$postcover],
			$optsplit->[2]];
	} else {
		return undef;
	}
}
