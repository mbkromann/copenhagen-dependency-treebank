sub component {
	my $self = shift;

	# Parameters
	my $outkey = "a";
	my $inkey = "b";

	# Create initial queue
	my $queue = {};
	foreach my $edge (@_) {
		$queue->{$edge} = $edge;
	}

	# Find all crossing edges
	my $E = $self->edges();
	my $edges = {};
	my ($omin, $omax, $imin, $imax) = (1e30, -1e30, 1e30, -1e30);
	while (my ($edge) = values(%$queue)) {
		# Read next edge in queue, and add it to edges hash
		delete $queue->{$edge};
		$edges->{$edge} = $edge;
		$omin = min($omin, @{$edge->outArray()}) 
			if ($edge->outkey() eq $outkey);
		$omax = max($omax, @{$edge->outArray()})
			if ($edge->outkey() eq $outkey);
		$imin = min($imin, @{$edge->inArray()})
			if ($edge->inkey() eq $inkey);
		$imax = max($imax, @{$edge->inArray()})
			if ($edge->inkey() eq $inkey);

		# Push all crossing edges onto queue
		map {$queue->{$_} = $_ if (! $edges->{$_})} 
			@{$self->crossings($edge)};

		# Find all intervening edges, if queue is empty
		if (! values(%$queue)) {
			# Intervening out-edges
			if ($omax < 1e30) {
				for (my $o = $omin; $o <= $omax; ++$o) {
					map {
						$queue->{$_} = $_ if (! exists $edges->{$_});
					} @{$self->node($outkey, $o)};
				}
			}

			# Intervening in-edges
			if ($imax < 1e30) {
				for (my $i = $imin; $i <= $imax; ++$i) {
					map {
						$queue->{$_} = $_ if (! exists $edges->{$_});
					} @{$self->node($inkey, $i)};
				}
			}
		}
	}

	# Sort edges
	my $sorted = [
		sort {
				# Deletion edges come first
				(($a->outkey() ne $a->inkey())
				<=>
				($b->outkey() ne $b->inkey())) 
				
				|| 

				# Preceding nodes in component
				((min(@{$a->outArray()}) 
					+ min(@{$a->inArray()})
					- $omin - $imin) 
				<=> 				
				(min(@{$b->outArray()}) 
					+ min(@{$b->inArray()})
					- $omin - $imin))
		} values(%$edges)
	];


	# Return all edges
	return $sorted;
}
