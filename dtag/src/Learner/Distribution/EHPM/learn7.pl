sub learn7 {
	my $self = shift;
	my $data = shift;
	my $true = shift;
	my $nparams = shift;

	# Calculate true mlogp
	my $true_mlogp = $nparams / 2 * log($data->count());
	foreach my $d (@{$data->data()}) {
		my $o = $data->outcome($d);
		my $fo = &$true($o);
		print DTAG::Interpreter::dumper($o) . " f=$fo\n";
		$true_mlogp -= log(&$true($o));
	}
	$self->var('true_mlogp', $true_mlogp);

	# Create root partition
	my $hierarchy = $self->hierarchy();
	my $root = DTAG::Learner::Partition->new();
	$self->total($data->count());
	$root->setup($self, $data, []);
	$root->compute_prior_mass($self, []);
	$self->cover([$root]);
	
	# Initialize states
	my $state = [$self->mlog_posterior($self->cover()), 
		$self->cover(), 'root'];
	$self->var('mlogp', $state->[0]);

	# Improve cover by local search
	my $changes = 0;
	my $maxchanges = 1000;
	my $nstate;
	my $next = 0;
	my $status = 1; 	# 0=init 1=partioning 2=pfail 4=merging 8=mfail
	do {
		# Increment depth and changes
		++$changes;
		my $cover = $state->[1];

		# Print current cover
		print $self->print_cover2("Action[$changes]: " .
			$state->[2], $state->[1], $state->[0]);

		# Find first possible partitioning
		$nstate = undef;
		for (my $ir = 0; $ir <= $#$cover && ($status & 1); ++$ir) {
			my $i = ($ir + $next) % ($#$cover + 1);
			print "    Partitioning $i\n";

			# Find optimal partitioning of $i
			my $partition = $cover->[$i];

			# Compute optimal partitioning, if necessary
			my $precover = [@$cover[0..$i-1]];
			my $postcover = [@$cover[($i+1)..$#$cover]];
			my $pstate = $partition->opt_partitioning();
			if ($pstate) {
				print $self->print_cover2("      cached",
					[@$precover, @{$pstate->[1]}, @$postcover],
					$pstate->[0]) if ($pstate->[1]);
			} else {
				$pstate = $partition->compute_opt_partitioning7($self,
					$precover, $postcover, $state->[0]);
			}
			next() if (! @$pstate);

			# Is the partition an improvement?
			if ($pstate->[0] < 0 
					&& ((! $nstate) 
						|| $pstate->[0] + $state->[0] < $nstate->[0])) { 
				# Compute reduced state
				my $rstate = $self->reduce([0, [@$precover, @{$pstate->[1]},
					@$postcover]]);
				$rstate->[0] = $self->mlog_posterior($rstate->[1]);

				# Is the reduced partition an improvement?
				if ($rstate->[0] < $state->[0] 
						&& ((! $nstate) || $rstate->[0] < $nstate->[0])) {
					$nstate = [$rstate->[0], $rstate->[1], "split $i"];
					$next = $i;
					$status = 1;
					last();
				} else {
					$partition->{'opt_partitioning'} = undef;
				}
			}
		}

		# Check whether partitioning was successful
		if (($status & 1) && ! $nstate) {
			$status = ($status & 8) ? 0 : 6;
			print "pstatus=$status\n";
			$next = 0;
		}

		# Find first possible merging
		for (my $ir = 0; $ir < $#$cover && ($status & 4); ++$ir) {
			# Attempt merge
			my $i = ($ir + $next) % ($#$cover + 1);
			my $mstate = $self->merge($cover, $i);
			next() if (! $mstate);
			my $rstate = $self->reduce($mstate);

			# Debug
			print $self->print_cover2("      merge $i",
				$rstate->[1], $rstate->[0] - $state->[0]);

			# Reduce merged state
			if ($rstate->[0] < $state->[0]) {
				$nstate = [$rstate->[0], $rstate->[1], "merge $i"];
				$next = $i;
				$status = 4;
				last();
			}
		}

		# Check whether merging was successful
		if (($status & 4) && ! $nstate) {
			print "mstatus=$status\n";
			if ($status & 2) {
				$status = 0;
			} else {
				$status = 1 + 8;
				$next = 0;
			}
		}

		# Set $state to $nstate
		$state = $nstate if ($nstate);

		# Recompute mlogp for $state
		#my $mlogp  = $self->mlog_posterior($state->[1]); 
		#if (abs($mlogp - $state->[0]) / max($mlogp, 1) > 0.001) {
		#	print "WARNING: mlog_posterior error: mlogp=$mlogp smlogp=" 
		#		. $state->[0] . "\n";
		#}
	} until ((! $status) || $changes > $maxchanges);

	# Exit
	$self->var('mlogp', $state->[0]);
	$self->cover($state->[1]);
	print $self->print_cover2("    Action[$changes]: exit",
		$state->[1], $state->[0]) if ($state);
	print "true_mlogp=" . $self->var('true_mlogp') . "\n";
		print(("-" x 60) . "\n");
}
