sub box_inside {
	my $self = shift;
	my $box = shift;
	my $x = shift;

	# Determine whether $x lies in $subspace
	return 0 if (! defined($box));

	# Debug
	#print "box_inside: " . 
	#	DTAG::Interpreter::dumper([$x, $box]) . "\n";

	# Determine whether $x lies in box
	my $dim = $self->dimension();
	for (my $i = 0; $i < $dim; ++$i) {
		return 0 if (($x->[$i] < $box->[$i][0])
			|| ($x->[$i] > $box->[$i][1]));
	}

	# No coordinate was outside box, so $x is inside
	return 1;
}
