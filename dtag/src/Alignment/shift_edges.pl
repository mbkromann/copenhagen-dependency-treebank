sub shift_edges {
	my $self = shift;
	my $key = shift || "?";
	my $node = shift || 0;
	my $shift = shift || 0;

	# Test that alignment key $key is legal
	if (! exists($self->{'graphs'}{$key})) {
		error("illegal alignment file key $key");
		return undef;
	}

	# Shift alignment edges
	my $newedges = [];
	foreach my $edge (@{$self->edges()}) {
		my $newedge = $self->shift_edge($edge, $key, $node, $shift) || $edge;
		push @$newedges, $newedge;
	}

	# Create new graph
	$self->set_edges($newedges);
}

sub shift_edge {
	my $self = shift;
	my $oldedge = shift;
	my $skey = shift;
	my $snode = shift;
	my $shift = shift;

	# No changes so far
	my $changed = 0;

	# Clone edge
	my $edge = $oldedge->clone();

	# Determine whether in- and out-array should be shifted
	my @arrays = ();
	my $inarray = ($edge->inkey() eq $skey) ? $edge->inArray() : undef;
	my $outarray = ($edge->outkey() eq $skey) ? $edge->outArray() : undef;
	push @arrays, $inarray if ($inarray);
	push @arrays, $outarray if ($outarray);

	# Shift each array
	foreach my $array (@arrays) {
		# Shift each node in array
		for (my $i = 0; $i <= $#$array; ++$i) {
			if ($array->[$i] >= $snode) {
				$changed = 1;
				$array->[$i] += $shift;
			}
		}
	}

	# Save arrays
	$edge->inArray($inarray) if ($inarray);
	$edge->outArray($outarray) if ($outarray);
	
	# Return shifted $edge, or undef if unmodified
	return $changed ? $edge : undef;
}
