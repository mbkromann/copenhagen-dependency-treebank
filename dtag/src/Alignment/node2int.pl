# Convert (key,node) to integer ID
sub node2int {
	my ($node, $key) = @_;
	return ($key eq "a" ? 1 : -1) * ($node + 1);
}

