sub min {
	my $min = shift;
	map {$min = $_ if ($_ < $min)} @_;
	return $min;
}

sub max {
	my $max = shift;
	map {$max = $_ if ($_ > $max)} @_;
	return $max;
}
