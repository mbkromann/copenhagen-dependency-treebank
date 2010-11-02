sub reduce {
	my $self = shift;
	my $split = shift;
	my $precover = shift || [];

	# Reduce cover
	my $rsplit = $split;
	for (my $i = 0; $i < $#{$rsplit->[1]}; ++$i) {
		# Fix partition $i in $rsplit if degenerate
		my $p = $rsplit->[1][$i];
		if ($p->count() < $self->mindata()
				# || $p->count() < $p->mlog_posterior() * $self->total()
			) {
			my $merged = $self->merge($rsplit->[1], $i, $precover);
			if ($merged && $merged->[1]) {
				$rsplit = $merged;
				--$i;
			}
		}
	}

	# Return
	return $rsplit;
}

