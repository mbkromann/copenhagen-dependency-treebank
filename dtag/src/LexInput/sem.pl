# 	sem($node, $type) := {$node} if it has semantic type $t, empty set
# 		otherwise
sub sem {
	return SemOp->new(shift, shift);
}

