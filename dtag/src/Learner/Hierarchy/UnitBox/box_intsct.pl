sub box_intsct {
	my $self = shift;
	my $box1 = shift;
	my @intsct = ();

	# Return empty list if @_ is empty
	return @intsct if (! @_);

	# Compute intersections
	foreach my $box2 (@_) {
		# Find intersection of the two boxes
		my $dim = $self->dimension();
		my $box = [];
		for (my $d = 0; $d < $dim; ++$d) {
			$box->[$d] = [];
			$box->[$d][0] = max($box1->[$d][0], $box2->[$d][0]);
			$box->[$d][1] = min($box1->[$d][1], $box2->[$d][1]);
			if ($box->[$d][0] >= $box->[$d][1]) {
				$box = undef;
				last();
			}
		}
		
		# Add box to list of boxes
		push @intsct, $box;
	}

	# Return box
	return @intsct;
}
