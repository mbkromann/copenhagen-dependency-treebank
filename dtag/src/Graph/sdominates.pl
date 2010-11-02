=item $graph->sdominates($lsite, $node) = $boolean

Return true if $lsite dominates $node in the surface tree, and false
otherwise.

=cut

sub sdominates {
	my $self = shift;
	my $lsite = shift;
	my $node = shift;
	my $yields = $self->var('yields');

	# Find yield segment containing $lsite, and check whether it
	# contains $node
	my ($start, $stop);
	foreach my $s (@{$yields->{$lsite}}) {
		# Fail if we skipped the yield segment containing $lsite
		return 0 if ($s->[0] > $lsite);

		# Check whether yield segment contains $node
		if ($s->[1] >= $lsite) {
			# Now yield segment contains $!node
			return ($s->[0] <= $node && $s->[1] >= $node) ? 1 : 0;
		}
	}

	# Failed to find yield segment containing both $lsite and $node
	return 0;
}
