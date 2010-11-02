#	parent($x) := all parents matching $x

sub parent {
	return ParentOp->new(shift);
}

