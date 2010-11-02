sub uniq {
	my $hash = {};
	my @uniq;

	while (@_) {
		my $arg = shift;
		if (! $hash->{$arg}) {
			push @uniq, $arg;
			$hash->{$arg} = 1;
		}
	}

	return @uniq;
}
