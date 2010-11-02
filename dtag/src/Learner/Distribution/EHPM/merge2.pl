sub merge2 {
	my $self = shift;
	my $cover = shift;
	my $child = shift;
	my $precover = shift || [];

	# Find parent of partition $child
	my $partition_box = $cover->[$child]->space_box();
	my $hierarchy = $self->hierarchy();
	my $parent = undef;
	for (my $j = $child+1; $j <= $#$cover; ++$j) {
		my $parent_box = $cover->[$j]->space_box();
		if ($hierarchy->box_contains($parent_box, $partition_box)) {
			$parent = $j;
			last();
		}
	}
	return undef if (! defined($parent));
	
	# Start by creating the new cover.
	my $newcover = [@$cover[0..($child-1)]];
	foreach my $p (@$cover[($child+1)..$parent]) {
		my $clone = $p->clone();
		my $dataclone = $p->data()->clone();
		$clone->data($dataclone);
		$dataclone->observations([@{$dataclone->observations}]);
		push @$newcover, $clone;
	}
	push @$newcover, @$cover[($parent+1)..$#$cover];

	# Add each observation in $cover->[$child] to the appropriate partition
	# in the new cover
	my $data = $cover->[$child]->data();
	foreach my $d (@{$data->observations()}) {
		# Find partition in $newcover containing $d
		my $k = $self->find_partition_index($data->outcome($d), $newcover);

		# Add observation to partition $k, if $child <= $k < $parent
		my $kdata = $newcover->[$k]->data();
		if ($child <= $k && $k < $parent) {
			$kdata->add($kdata->outcome($d));
			$newcover->[$k]->{'subdata'} = undef;
		}
	}

	# Compute prior mass for each partition after $child
	for (my $j = $child; $j < $parent; ++$j) {
		my $p = $newcover->[$j];
		my $prior_mass = $p->compute_prior_mass($self, [@$precover, 
			@$newcover[0..$j-1]]);

		# Reject if prior mass is non-positive
		if ($prior_mass <= 0) {
			$p->prior_mass(0);
			print "ERROR: illegal prior mass when merging "
				. " from " . $self->print_cover($cover) . "\n";
			# return [1e100, undef];
		}
	}

	# Compute mlog_posterior
	my $mlog_posterior = 0;
	for (my $j = 0; $j <= $#$newcover; ++$j) {
		# Compute mlog_posterior, if necessary
		my $p = $newcover->[$j];
		if ($child <= $j && $j < $parent) {
			$p->compute_mlog_posterior($self);
			$p->{'opt_partitioning'} = undef;
		}

		# Compute total mlog_posterior
		$mlog_posterior += $p->mlog_posterior();
	}

	# Return cover and mlog_posterior
	return [$mlog_posterior, $newcover];
}

