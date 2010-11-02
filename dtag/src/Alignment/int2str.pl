# convert integer to node string
sub int2str {
	my ($int) = @_;
	return ($int > 0 ? "a" : "b") . (abs($int) - 1), 
}

