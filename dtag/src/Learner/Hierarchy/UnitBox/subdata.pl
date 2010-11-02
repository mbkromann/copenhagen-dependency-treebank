sub subdata {
	my $self = shift;
	my $subspace = shift;
	my $data = shift;
	my $mindata = shift || 5;

	# Calculate parameters
	my $dim = $self->dimension();
	my $branch = $self->branching();

	# Calculate box corresponding to planes
	my $box = $self->space2box($subspace);
	return [] if (! defined($box));

	# Find only subdivisions with non-zero counts
	my $hash = {};
	foreach my $d (@{$data->data()}) {
		# Find all planes containing datum
		my $x = $data->outcome($d);
		for (my $i = 0; $i < $dim; ++$i) {
			# Find plane containing datum
			my $min = $box->[$i][0];
			my $max = $box->[$i][1];
			my $pos = int($branch * ($x->[$i] - $min) / ($max - $min));

			# Record datum in plane hash	
			my $list = $hash->{"$i:$pos"} = $hash->{"$i:$pos"} || [];
			push @$list, $d;
		}
	}

	# Create subdata by decreasing frequency
	my $subdata = [];
	foreach my $planeid (sort {scalar(@{$hash->{$b}}) 
			<=> scalar(@{$hash->{$a}})} keys(%$hash)) {
		# Skip subdata if it violates minimum data count
		last() if (scalar(@{$hash->{$planeid}}) <= $mindata);

		# Calculate new plane
		my ($i, $pos) = split(':', $planeid);
		my $min = $box->[$i][0];
		my $max = $box->[$i][1];
		my $newmin = $min + $pos * ($max - $min) / $branch;
		my $newmax = $min + ($pos + 1) * ($max - $min) / $branch;

		# Calculate new data
		my $newdata = $data->clone();
		$newdata->data($hash->{$planeid});
		$newdata->plane([[$i, $newmin, $newmax]]);

		# Store new data as a subdivision
		push @$subdata, $newdata;
	}

	# Return subdata
	return $subdata;
}


