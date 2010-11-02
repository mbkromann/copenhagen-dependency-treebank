# 	is($node, $type) := 1 if $node has type $type, 0 otherwise
sub is {
	return IsOp->new(shift, shift);
}

