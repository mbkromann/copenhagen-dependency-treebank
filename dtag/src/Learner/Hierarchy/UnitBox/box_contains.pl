sub box_contains {
	my $self = shift;
	my $box1 = shift;
	my $box2 = shift;

	# Check whether $box1 contains $box2
	my $dim = $self->dimension();
	for (my $d = 0; $d < $dim; ++$d) {
		return 0 
			if (($box1->[$d][0] > $box2->[$d][0]
				|| ($box1->[$d][1] < $box2->[$d][1])));
	}

	# $box1 contains $box2
	return 1;
} 
