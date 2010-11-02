# 	diff($type, $type1, $type2) := all super types of $type1
# 		dominated by $type, but not dominating $type2
sub diff {
	return DiffOp->new(shift, shift, shift);
}

