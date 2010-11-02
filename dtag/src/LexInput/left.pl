# 	left($type) := all left landed nodes matching $type
sub left {
	return LeftOp->new(shift);
}

