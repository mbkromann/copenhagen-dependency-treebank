sub learn5 {
	my $self = shift;
	my $data = shift;
	my $hierarchy = $self->hierarchy();

	# Create root partition
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);
	$self->cover([$root]);
	
	# Create cover hash with visited covers
	my $visited = {};

	# Initialize states
	my $state = [$self->mlog_posterior($self->cover()), 
		$self->cover(), 'root'];
	my $lstate = $state; 
	my $gstate = undef;

	# Initialize depths and changes
	my $depth = 0;
	my $maxdepth = 30;
	my $changes = 0;

	# Improve cover by local search
	while ($depth < $maxdepth && defined($lstate)) {
		# Increment depth and changes
		++$depth;
		++$changes;
		my $skip = 0;
		my $mlogp_old = $lstate->[0];
		my $cover = $lstate->[1];
		$visited->{$self->print_cover($cover)} += 1;

		# Print current cover
		print $self->print_cover2(
			($depth > 1 ? "DEPTH $depth: " : ""),
			$cover, 
			$lstate->[0]);

		# Reset locally optimal cover
		$lstate = undef;

		# Merge partitions with fewer than $mindata observations
		for (my $i = 0; $i < $#$cover; ++$i) {
			if ($cover->[$i]->count() < $self->mindata()
					|| $cover->[$i]->count() < $self->total()
						* $cover->[$i]->prior_mass()) {
				# Compute optimal cover produced by merging and its weight
				my $mstate = $self->merge($cover, $i);

				# Use the merging of $i, unless previously visited
				if ($mstate && $mstate->[1]) {
					if ($visited->{$self->print_cover($mstate->[1])}) {
						print $self->print_cover2("REJECTED merge!", 
							$mstate->[1], $mstate->[0]);
					} else {
						$lstate = [-1e100, $mstate->[1], "merge! $i"];
						$skip = 1;
						last();
					}
				}
			}
		}
		
		# Proceed with partitions and mergings, unless asked to skip
		if (! $skip) {
			# Find optimal partitionings of each class
			for (my $i = 0; $i <= $#$cover; ++$i) {
				# Debug
				print "    Partitioning $i\n";

				# Find optimal partitioning of the partition
				my $partition = $cover->[$i];
				my $pstate = $partition->opt_partitioning()
					|| $partition->compute_opt_partitioning5($self,
						[@$cover[0..$i-1]], [@$cover[($i+1)..$#$cover]],
						$mlogp_old);

				# Use partitioning if better than $lstate
				if ($pstate && $pstate->[1] && (((! $lstate) 
						|| $pstate->[0] + $state->[0] < $lstate->[0]))) {
					if (($visited->{$self->print_cover($pstate->[1])} 
							|| 0) > 1) {
						print $self->print_cover2("REJECTED split $i", 
							$pstate->[1], $pstate->[0]);
					} else {
						$lstate = [$pstate->[0] + $state->[0],
							$pstate->[1], "split $i"];
					}
				}
			}
		
			# Find optimal mergings of each class
			for (my $i = 0; $i < $#$cover; ++$i) {
				# Compute optimal cover produced by merging and its weight
				my $mstate = $self->merging2($cover, $i);

				# Use merging if better than $lstate
				if ($mstate && $mstate->[1] 
						&& ((! $lstate) || $mstate->[0] < $lstate->[0])) {
					if ($visited->{$self->print_cover($mstate->[1])}) {
						print $self->print_cover2("REJECTED merge $i", 
							$mstate->[1], $mstate->[0]);
					} else {	
						$lstate = [$mstate->[0], $mstate->[1], "merge $i"];
					}
				}
			}
		}
		

		# Process locally optimal state
		print(("-" x 60) . "\n");
		if ($lstate) {
			# Reset partitions in mergings
			if ($lstate->[2] =~ /^merge!? ([0-9]*)$/) {
				# Merging: reset partitions $i, ... in $opt_cover
				for (my $i = $1; $i < scalar(@{$lstate->[1]}); ++$i) {
					$lstate->[1][$i]->opt_partitioning(undef);
				}
			}

			# Recompute mlogp for $lstate
			$lstate->[0] = $self->mlog_posterior($lstate->[1]);

			# Print performed action
			print $self->print_cover2("Action[$changes]: " .
				$lstate->[2], $lstate->[1], $lstate->[0]);

			# Promote $lstate to $gstate if better
			if ((! $gstate) || $lstate->[0] < $gstate->[0]) {
				$gstate = $lstate;
			}

			# Promote $gstate to $state if better
			if ($gstate->[0] < $state->[0]) {
				print $self->print_cover2("    gstate:", 
					$gstate->[1], $gstate->[0]);
				print $self->print_cover2("    state:", 
					$state->[1], $state->[0]);
	
				# Check that $state is nondegenerate!
				my $degenerate = 0;
				for (my $i = 0; $i < $#{$gstate->[1]}; ++$i) {				
					if ($gstate->[1][$i]->count() < $self->mindata()
						|| $gstate->[1][$i]->count() < $self->total()
							* $gstate->[1][$i]->prior_mass()) {
						$degenerate = 1;
						last();
					}
				}

				# Only promote non-degenerate
				if (! $degenerate) {
					$state = $gstate;
					$self->cover($state->[1]);
					$depth = 0;
					print "    IMPROVEMENT\n";
				} else {
					print "    DEGENERATE\n";
				}
			}
		} else {
			print $self->print_cover2("    Action[$changes]: exit",
					$state->[1], $state->[0]);
		}
		print(("-" x 60) . "\n");
	}
}

