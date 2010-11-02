#	child($x) := all children matching $x

sub child {
	return ChildOp->new(shift);
}

