#	dist($node) := distance to $node, measured as intervening words 
sub dist {
	return DistOp->new(shift);
}

