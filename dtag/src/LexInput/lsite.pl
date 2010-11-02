# 	lsite($type) := all landing sites matching $type
sub lsite {
	return LsiteOp->new(shift);
}

