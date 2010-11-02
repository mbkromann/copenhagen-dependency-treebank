# split = [$mlog_post, $cover, $info, $moved]

sub compute_opt_partitioning6 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];
	my $mlogp_old = shift || 0;

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self], 0];
	my $loptsplit = $split; 
	my $optsplit = undef;
	my $maxdepth = 100;
	my $depth = 0;
	my $newcover;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth 
			&& ((! $optsplit) || $optsplit->[0] >= 0)) {
		# Increment depth
		++$depth;
		#print $distribution->print_cover2("      PDEPTH $depth",
		#	[@$precover, @{$split->[1]}, @$postcover],
		#	$mlogp_old + $loptsplit->[0]) if ($depth > 1);

		# Reset best split at current depth
		$loptsplit = undef;

		# Find all partitionings of partitions in cover, and select
		# partitioning with maximal count
		my $cover = $split->[1];
		my $maxsplit = undef;
		for (my $i = 0; $i <= $#$cover; ++$i) {
			my $partition = $cover->[$i];
			my $subdata = $partition->var('subdata') ||
				$partition->var('subdata', 
					$distribution->hierarchy()->subdata2(
						$partition->space(), $partition->data(), 
						$distribution->mindata()));
			my $count = @$subdata ? $subdata->[0]->count() : 0;
			if ($count && ((! defined($maxsplit)) || $count > $maxsplit->[0])) {
				$maxsplit = [$count, $i];
			}
		}

		# Exit if no partitionings found
		last() if (! $maxsplit);

		# Now create new cover...
		my $super = $cover->[$maxsplit->[1]];
		my $d = $super->var('subdata')->[0];

		# ... setup child
		my $child = $super->clone();
		$child->setup($distribution, $d, $d->plane(), $super);

		# ... find all observations in $super that are not in child
		my $hash = {};
		my $list = [];
		map {$hash->{$_} = 1} @{$child->data()->observations()};
		map {push @$list, $_ if (! $hash->{$_})}
			@{$super->data()->observations()};
			
		# ... setup parent
		my $pdata = $super->data()->clone();
		$pdata->observations($list);
		my $parent = $super->clone();
		$parent->init($distribution, $pdata, $super->plane(), 
			$super->space());

		# ... compute prior probability mass of child and parent
		$child->compute_prior_mass($distribution, $precover);
		$parent->compute_prior_mass($distribution, [@$precover, $child]);

		# Compute new cover
		my $i = $maxsplit->[1];
		$newcover = [@$cover[0..($i-1)], $child, $parent, 
			@$cover[($i+1)..$#$cover]];

		# ... compute posterior probability of child and parent
		$child->compute_mlog_posterior($distribution);
		$parent->compute_mlog_posterior($distribution);

		# Delete parent if it is degenerate
		if ($parent != $self && ($parent->count() < $distribution->mindata())) {
			my $merged = $distribution->merge($newcover, $i+1, $precover);
			if ($merged && $merged->[1]) {
				$loptsplit = $merged;
			}
		} 
		my $mlogp = $distribution->mlog_posterior([@$precover,
			@$newcover, @$postcover]);
		$loptsplit = [$mlogp, $newcover];

		# Debug
		print $distribution->print_cover2("      split",
			[@$precover, @{$loptsplit->[1]}, @$postcover], $mlogp);


		# Use locally optimal split as new split, and as globally
		# optimal split if it is better than old globally optimal split
		$split = $loptsplit;
		if ($loptsplit && ((! $optsplit) 
				|| ($loptsplit->[0] < $optsplit->[0]))) {
			$optsplit = $loptsplit;
		}
	}

	# Delete all degenerate nodes
	if ($optsplit && 0) {
		$newcover = [@$precover, @{$optsplit->[1]}, @$postcover];
		print $distribution->print_cover2("***", $newcover, 0) . "\n"; 
		my $maxi = scalar(@$precover) + scalar(@{$optsplit->[1]});
		for (my $i = scalar(@$precover); $i < $maxi; ++$i) {
			my $p = $newcover->[$i]; 
			if ($p->count() < $distribution->mindata()
				|| $p->count() < $distribution->total() *
					$p->prior_mass()) {
				my $merged = $distribution->merge($newcover, $i);
				if ($merged && $merged->[1]) {
					$newcover = $merged->[1];
					--$maxi; 
					--$i;
				}
			}
		}
		my $mlogp = $distribution->mlog_posterior($newcover);
		$optsplit = [$mlogp, $newcover];
	} 


	# Return optimal partitioning
	return $optsplit 
		? [$optsplit->[0], [@$precover, @{$optsplit->[1]}, @$postcover],
			$optsplit->[2]]
		: undef;
}
