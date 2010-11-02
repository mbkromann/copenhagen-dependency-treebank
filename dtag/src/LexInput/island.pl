# 	island($type) := all nodes that extract through a child edge of 
#		type $type
sub island {
	return IslandOp->new(shift);
}
