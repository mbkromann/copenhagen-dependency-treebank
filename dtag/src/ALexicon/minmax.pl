sub min {
	my $min = shift;
	my $next;
	while (@_) {
		$min = $_[0] if (defined($_[0]) && ((! defined($min)) || $min > $_[0]));
		shift();
	}
	return $min;
}

sub max {
	my $max = shift;
	while (@_) {
		$max = $_[0] if (defined($_[0]) && ((! defined($max)) || $max < $_[0]));
		shift();
	}
	return $max;
}

