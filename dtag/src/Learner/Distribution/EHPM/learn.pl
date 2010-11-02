sub learn {
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
		my $action = [0,[]];
		$optimal = 1;

		# Print current cover
		print "optimal cover: (" . join(", ", 
			map { join("x", 
					map { "[" . sprintf("%.4g", $_->[0]) . "," 
							. sprintf("%.4g", $_->[1]) . "]"
					} @{$_->space_box()})
			} @$opt_cover) . ") with posterior=$opt_mlog_posterior\n";
		print "counts: " . 
			join(" ", map {scalar(@{$_->data()->data()})} @$opt_cover)
				. "\n";

		# Find optimal partitionings of each class
		my $cover = $self->cover();
		for (my $i = 0; $i < scalar(@$cover); ++$i) {
			# Find optimal partitioning of the partition
			my $partition = $cover->[$i];
			my $partitioning = $partition->opt_partitioning()
				|| $partition->compute_opt_partitioning($self,
					[@$cover[0..$i-1]]);

			# Use the locally optimal partitioning, if it is better than the 
			# currently optimal cover
			if ($old_mlog_posterior + $partitioning->[0] 
					< $opt_mlog_posterior) {
				$optimal = 0;
				$opt_mlog_posterior = $old_mlog_posterior + $partitioning->[0];
				$opt_cover = $self->partitioning2cover($i, $partitioning);
				$action = [1, $partitioning, $i];
			}
		}
		
		# Find optimal mergings of each class
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

		# Debug
		if ($action->[0] == 0) {
			print "    Action: exit\n";
		} elsif ($action->[0] == 1) {
			print "    Action: partitioning " 
				. $action->[2] . ": " 
				. $hierarchy->print_box($action->[1][2]->space_box()) 
				. " into " 
				. $hierarchy->print_box($action->[1][1]->space_box()) . "\n";
		} elsif ($action->[0] == 2) {
			print "    Action: merging "
				. $action->[2] . "\n";
		}
		 
		# Set optimal cover
		$self->cover($opt_cover);
	}
}
