# 	gov($type) := all governors matching $type
sub gov {
	return GovOp->new(shift);
}

