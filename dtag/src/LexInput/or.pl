#	or($x1, ..., $xN) := abs($x1) + ... + abs($xN)

sub or {
	return OrOp->new(@_);
}

sub OR {
	return OrOp->new(@_);
}
