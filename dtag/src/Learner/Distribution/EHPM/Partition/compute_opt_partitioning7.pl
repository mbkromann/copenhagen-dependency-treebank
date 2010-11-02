# split = [$mlog_post, $cover, $info, $moved]

sub compute_opt_partitioning7 {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];
	my $postcover = shift || [];
	my $mlogp_old = shift;

	# Initial optimal partitioning is to do nothing at all
	my $split = [0, [$self]];
	my $optsplit = [0];
	my $maxdepth = $distribution->var('maxdepth') || 20;
	my $depth = 0;

	# Process subdata to find better partitionings
	while ($split && $depth < $maxdepth && $optsplit->[0] >= 0) {
		# Increment depth
		++$depth;

		# Save current cover
		my ($mlogp, $cover)  = @$split;

		# Reset current split
		$split = undef;

		# Find all partitionings of partitions in cover, and select
		# partitioning with maximal count
		my $maxcount = undef;
		for (my $i = 0; $i <= $#$cover; ++$i) {
			my $partition = $cover->[$i];
			my $subdata = $partition->var('subdata') ||
				$partition->var('subdata', 
					$distribution->hierarchy()->subdata2(
						$partition->space(), $partition->data(), 
						$distribution->mindata()));
			my $count = @$subdata ? $subdata->[0]->count() : 0;
			if ($count && ((! $maxcount) || $count > $maxcount->[0])) {
				$maxcount = [$count, $i];
			}
		}

		# Stop search if no partitionings found
		if (! $maxcount) {
			print "     stop\n";
		 	last();
		}

		# Find partition to split and associated splitting data
		my $isplit = $maxcount->[1];
		my $super = $cover->[$isplit];
		my $d = $super->var('subdata')->[0];

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
		my $parent = $super->clone();
		my $pdata = $super->data()->clone();
		$pdata->observations($list);
		$parent->init($distribution, $pdata, $super->plane(), 
			$super->space());

		# Compute prior probability mass of child and parent
		$child->compute_prior_mass($distribution, $precover);
		$parent->compute_prior_mass($distribution, [@$precover, $child]);

		# Compute new cover
		my $newcover = [@$cover[0..($isplit-1)], $child, $parent, 
			@$cover[($isplit+1)..$#$cover]];

		# Compute posterior probability of child and parent
		$child->compute_mlog_posterior($distribution);
		$parent->compute_mlog_posterior($distribution);

		# Compute new mlogp
		my $mlogp_new  = $distribution->mlog_posterior([@$precover,
			@$newcover, @$postcover]);

		# Compute new split
		$split = [$mlogp_new - $mlogp_old, $newcover];

		# Compute reduced non-degenerate split 
		my $rsplit = $distribution->reduce([$mlogp_new, 
			[@$precover, @{$split->[1]}, @$postcover]]);
		$rsplit->[0] = $distribution->mlog_posterior($rsplit->[1])
			- $mlogp_old;

		# Use $rsplit as $optslit if better than current $optsplit
		if ($rsplit->[0] < $optsplit->[0]) {
			$optsplit = $rsplit;
		}

		# Debug
		print $distribution->print_cover2("      split ",
			[@$precover, @{$split->[1]}, @$postcover], $split->[0]);
		print $distribution->print_cover2("      rsplit",
			$rsplit->[1], $rsplit->[0]);
	}

	# Return optimal partitioning
	print $distribution->print_cover2("      esplit",
		[@$precover, @{$split->[1]}, @$postcover], 
		$optsplit->[0]) if ($optsplit->[1]);

	return $self->opt_partitioning($optsplit->[1] 
		? [$optsplit->[0], $split->[1]] : []);
}
