#	not($x) := 1 if abs($x) = 0, 0 otherwise

sub not {
	return NotOp->new(@_);
}

sub NOT {
	return NotOp->new(@_);
}
