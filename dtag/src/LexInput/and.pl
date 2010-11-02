#	and($x1, ..., $xN) := abs($x1) * ... * abs($xN)

sub and {
	return AndOp->new(@_);
}

sub AND {
	return AndOp->new(@_);
}

