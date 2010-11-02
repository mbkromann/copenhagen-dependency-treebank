# convert integer to key and node
sub int2node {
	my ($int) = @_;
	return (abs($int) - 1, $int > 0 ? "a" : "b");
}

