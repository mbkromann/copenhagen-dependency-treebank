=item $graph->yield_simplify(@intervals) = @newintervals

Compute simplified set of intervals from @intervals = ([$start1,
$stop1], ...), and return in @newintervals.

=cut

sub yield_simplify {
	my $self = shift;

	# Sort intervals in yield according to start element
	my @yield = sort {$a->[0] <=> $b->[0]} @_;

	# Merge intervals into one
	my @new = ();
	my $interval = shift(@yield);
	my $start = $interval->[0];
	my $stop = $interval->[1];

	# Process intervals
	my $saved;
	foreach $interval (@yield) {
		# Skip comment nodes
		while ($self->node($stop+1)->comment()) {
			++$stop;
		}

		# Read next interval
		my $start2 = $interval->[0];
		my $stop2 = $interval->[1];

		# Determine whether intervals overlap
		if ($start2 <= $stop + 1) {
			# Intervals overlap
			$stop = $stop2 if ($stop2 > $stop);
		} else {
			# Intervals do not overlap
			push @new, [$start, $stop];
			$start = $start2;
			$stop = $stop2;
		}
	}

	# Save last interval
	push @new, [$start, $stop];

	# Return simplified yield
	return @new;
}

