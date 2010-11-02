sub compute_opt_partitioning {
	my $self = shift;
	my $distribution = shift;
	my $precover = shift || [];

	# Find all partitionings of data
	my $subdata = $distribution->hierarchy()->subdata2(
		$self->space(), $self->data(), $distribution->mindata());
	
	# Initial optimal partitioning is to do nothing at all
	my $opt_partitioning = [0, undef, undef];

	# Process subdata to find better partitionings
	foreach my $d (@$subdata) {
		# Setup child
		my $child = $self->clone();
		$child->setup($distribution, $d, $d->plane(), $self);

		# Find all observations in $self that are not in child
		my $hash = {};
		my $list = [];
		map {$hash->{$_} = 1} @{$child->data()->observations()};
		map {push @$list, $_ if (! $hash->{$_})}
			@{$self->data()->observations()};
		
		# Setup parent
		my $pdata = $self->data()->clone();
		$pdata->observations($list);
		my $parent = $self->clone();
		$parent->init($distribution, $pdata, $self->plane(), $self->space());

		# Compute prior probability mass of child and parent
		$child->compute_prior_mass($distribution, $precover);
		$parent->compute_prior_mass($distribution, [@$precover, $child]);

		# Compute posterior probability of child and parent
		my $delta = $child->compute_mlog_posterior($distribution)
			+ $parent->compute_mlog_posterior($distribution) 
			- $self->mlog_posterior();

		# Debug
		print "    delta=" .
			sprintf("%.4g", $delta)
			. " splitting " 
			. $distribution->hierarchy()->print_box($self->space_box()) 
			. " with " 
			. $distribution->hierarchy()->print_plane($d->plane())
			. "\n";

		# If $delta is smaller than $opt_delta, then new partitioning
		# is currently optimal
		if ($delta < $opt_partitioning->[0]) {
			$opt_partitioning = [$delta, $child, $parent];
		}
	}

	# Set optimal delta and partitioning
	$self->opt_partitioning($opt_partitioning);
}
