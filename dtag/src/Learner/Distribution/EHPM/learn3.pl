sub learn3 {
	my $self = shift;
	my $data = shift;
	my $hierarchy = $self->hierarchy();

	# Create root partition
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);

	# Initialize cover
	$self->cover([$root]);

	# Improve cover by local search
	my $optimal = 0;
	my $changes = 0;
	while ((! $optimal) && $changes < 1000) {
		++$changes;

		# The current cover is optimal until proven otherwise
		my $opt_mlog_posterior = $self->mlog_posterior($self->cover());
		my $old_mlog_posterior = $opt_mlog_posterior;
		my $opt_cover = $self->cover();
		my $opt_moved = 0;
		my $action = [0,[]];
		$optimal = 1;

		# Print current cover
		print "cover=" . 
			$self->print_cover($opt_cover)
			. " counts=[" . 
				join(",", map {scalar(@{$_->data()->data()})} @$opt_cover)
				. "]"
			. " posterior=" .
				sprintf("%6g", $opt_mlog_posterior) . "\n"; 

		# Merge partitions with fewer than $mindata observations
		my $cover = $self->cover();
		for (my $i = 1; $i < scalar(@$cover) - 1; ++$i) {
			if ($cover->[$i]->count() < $self->mindata()) {
				# Compute optimal cover produced by merging and its weight
				my $merging = $self->merging($cover, $i, $old_mlog_posterior);

				# Use the merging of $i
				if (defined($merging->[1])) {
					$optimal = 0;
					$opt_mlog_posterior = -1e100;
					$opt_cover = $merging->[1];
					$action = [2, $merging, $i];
				}
			}
		}
		
		# Find optimal partitionings of each class
		if ($optimal) {
			for (my $i = 0; $i < scalar(@$cover); ++$i) {
				# Find optimal partitioning of the partition
				my $partition = $cover->[$i];
				my $partitioning = $partition->opt_partitioning()
					|| $partition->compute_opt_partitioning3($self,
						[@$cover[0..$i-1]], [@$cover[($i+1)..$#$cover]]);

				# Use the locally optimal partitioning, if it is better than the 
				# currently optimal cover
				#if ($partitioning && $old_mlog_posterior + $partitioning->[0] 
				#		< $opt_mlog_posterior) {
				if ($partitioning && $partitioning->[0] < 0 
					&& $opt_moved < $partitioning->[2]) {
					$optimal = 0;
					$opt_mlog_posterior = $old_mlog_posterior 
						+ $partitioning->[0];
					$opt_moved = $partitioning->[2];
					$opt_cover = $partitioning->[1];
					$action = [1, $partitioning, $i];
				}
			}
		}
		
		# Find optimal mergings of each class
		if ($optimal) {
			for (my $i = 1; $i < scalar(@$cover) - 1; ++$i) {
				# Compute optimal cover produced by merging and its weight
				my $merging = $self->merging($cover, $i, $old_mlog_posterior);

				# Use the merging of $i, if it is better than the
				# currently optimal cover
				if ($merging->[0] < $opt_mlog_posterior) {
					$optimal = 0;
					$opt_mlog_posterior = $merging->[0];
					$opt_cover = $merging->[1];
					$action = [2, $merging, $i];
				}
			}
		}

		# Reset optimal partitionings of affected partitions
		if ($action->[0] == 1) {
			# Partitioning: reset partition $i
			#my $partitioning = $action->[1];
			#foreach my $partition (@$partitioning[1..$#$partitioning]) {
			#	$partition->opt_partitioning(undef);
			#}
		} elsif ($action->[0] == 2) {
			# Merging: reset partitions $i, ... in $opt_cover
			for (my $i = $action->[2]; $i <= $#$opt_cover; ++$i) {
				$opt_cover->[$i]->opt_partitioning(undef);
			}
		}

		# Debug
		if ($action->[0] == 0) {
			print "    Action: exit\n";
		} elsif ($action->[0] == 1) {
			print "    Action: split " 
				. $self->print_cover($opt_cover) . "\n";
		} elsif ($action->[0] == 2) {
			print "    Action: merge"
				. $self->print_cover($opt_cover) . "\n";
		}

		# Sanitize optimal cover: include only partitions with more
		# than 

		# Set optimal cover
		$self->cover($opt_cover);
	}
}
