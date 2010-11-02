sub learn {
	my $self = shift;
	print $self->print_split() . "\n";
	
	# Continue subpartitioning space until there are no more partitions
	my $partitions = $self->compute_partitions();
	while (@$partitions) {
		# Find optimal partition and its parameters
		my $partition = $partitions->[0];
		my $moved = $partition->[2];

		if (abs($moved) < $minmoved / $total) {
			$partitions = [];
		} else {
			# Split space with partition
			my $subspace = $self->split(@$partition);

			# Split subspace recursively
			$subspace->learn();

			# Compute new set of partitions for this space
			$partitions = $self->compute_partitions();
		}
	}
}

