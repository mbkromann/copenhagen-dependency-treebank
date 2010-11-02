# 	dep($type) := all dependents matching $type
sub dep {
	return DepOp->new(shift);
}

