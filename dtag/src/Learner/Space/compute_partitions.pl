sub compute_partitions {
	my $self = shift;

	# Find parameters of remaining space
	my $box = $self->box();
	my $data = $self->rdata();
	my $phat = $self->rphat();
	my $weight = $self->rweight();
	my $mass = $weight * $phat;
	my $count = $self->count();

	# Exit if number of data is too small
	return [] if (scalar(@$data) < $mincount);

	# Optimal partition
	my $opt_val = 0;
	my $opt_pdata = undef;

	# For each dimension, try all immediate subtypes
	my $partitions = [];
	for (my $dim = 0; $dim < scalar(@$box); ++$dim) {
		# Find type in dimension $dim
		my $type = $box->[$dim];
		my $subtypes = $lexicon->subtypes($type);

		# Partition data for dimension $dim
		my $partition = $self->partition_data($data, $dim, $subtypes);
		my $sbox = [@$box];			

		# Create partition consisting of all subspaces with count >=
		# $mincount, and lump together all spaces with count <
		# $mincount into one big default space
		foreach my $s (@$subtypes) {
			my $scount = scalar(@{$partition->{$s}});
			if (scalar($scount >= $mincount)) {
				# Calculate prior probability of subspace
				$sbox->[$dim] = $s;
				my $pdata = [$dim, $s, 
					@{$self->split_params($sbox, $partition->{$s})}];
				my $val = $pdata->[2];

				# Save partition if $sphat and $rphat are legal
				push @$partitions, $pdata
					if ($pdata->[3] != 0 && $pdata->[4] != 0);

				# Find optimal partition
				if ($val > $opt_val) {
					$opt_val = $val;
					$opt_pdata = $pdata;
				}
			}
		}
	}

	# Return partitions, with optimal partition as first element
	return $opt_pdata
		? [$opt_pdata, grep {$_ != $opt_pdata} @$partitions]
		: [];
}

