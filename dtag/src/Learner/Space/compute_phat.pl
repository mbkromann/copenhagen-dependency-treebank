# Calculate cdf of this space minus all superiors and subspaces
sub compute_phat {
	my $self = shift;
	my $space = shift;
	
	# Find superiors if $space is empty
	if (! $space) {
		my $box = $self->box();
		my @superiors = map {$_->box()} 
			(@{$self->subspaces()}, @{$self->superiors()});
		my $n = scalar(@superiors);
		if ($n >= 1) {
			$space = ['-', $self->box(), @superiors];
		} else {
			return &$prior($box);
		}
	}

	# Reduce space
	my $op = $space->[0];
	if ($op ne '-' && $op ne '+') {
		# Space is a simple box
		return &$prior($space);
	} else {
		# Space is composite
		#     phat(A1-(A2+..+An)) := phat(A1)-phat(A1 & (A2+...+An))
		#     phat(A1 + ... + An) 
		#         = phat(A1) + phat(A2+...+An) - phat(A1 & (A2+...+An))
		my $n = scalar(@$space) - 1;
		my $a1 = $space->[1];
		my $phat = &$prior($a1);

		# In set union, add phat(A2+...+An)
		if ($op eq '+') {
			# Add union A2+...+An
			$phat += $self->compute_phat(
				($n <= 2) ? $space->[2] : ['+', @{$space}[2..$n]]);
		} 

		# Subtract union (A1&A2)+...+(A1&An)
		my $union = ['+'];
		my $intsct;
		for (my $i = 2; $i <= $n; ++$i) {
			# Find intersection of A1 and Ai, and save it if non-empty
			$intsct = $self->intsct($a1, $space->[$i]);
			push @$union, $intsct
				if ($intsct);
		}
		if (scalar(@$union) > 2) {
			$phat -= $self->compute_phat($union);
		} elsif (scalar(@$union) == 2) {
			$phat -= &$prior($union->[1]);
		}
			
		# Compute phat
		return $phat;
	}
}

