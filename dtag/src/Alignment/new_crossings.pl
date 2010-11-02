sub new_crossings {
	my $self = shift;
	my $newedge = shift;

	# Find keys
	my $inkey = $newedge->inkey();
	my $ingraph = $self->graph($inkey);

	# Find first edge $before entirely before $newedge
	my $before;
	for (my $i = min(@{$newedge->inArray()}) - 1; $i >= 0 && ! $before; --$i) {
		foreach my $e (@{$self->node($inkey, $i)}) {
			if ($e->before($newedge)) {
				$before = $e;
				last();
			}
		}
	}

	# Find first edge $after entirely after $newedge
	my $after;
	my $imax = $ingraph->size();
	for (my $i = max(@{$newedge->inArray()}) + 1; 
			($i < $imax  && ! $after); ++$i) {
		foreach my $e (@{$self->node($inkey, $i)}) {
			if ($e->after($newedge)) {
				$after = $e;
				last();
			}
		}
	}

	# Initialize list of candidates for crossings
	my $candidates = [
		@{$before ? $self->crossings($before) : []},
		@{$after ? $self->crossings($after) : []}
	];

	# Add all edges between $before and $after to candidate list
	my $i1 = $before ? min(@{$before->inArray()}) : 0;
	my $i2 = $after ? max(@{$after->inArray()}) : $ingraph->size() - 1;
	for (my $i = $i1; $i <= $i2; ++$i) {
		push @$candidates,
			@{$self->node($inkey, $i)};
	}
	
	# Examine all candidate edges
	my $crossing = {};
	foreach my $edge (@$candidates) {
		$crossing->{$edge} = $edge
			if ($edge->crossing($newedge) && $edge ne $newedge);
	}

	# Return crossing edges
	return [ values(%$crossing) ];
}
