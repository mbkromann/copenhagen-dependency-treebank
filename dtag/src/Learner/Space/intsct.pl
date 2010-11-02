sub intsct {
	my $self = shift;
	my $box1 = shift;
	my $box2 = shift;
	my $intsct = [];

	# Find intersection of boxes
	my $type;
	for (my $i = 0; $i < scalar(@$box1); ++$i) {
		# Find intersection of coordinates
		$type = $lexicon->intsct($box1->[$i], $box2->[$i]);
		return undef if (! $type);

		# Save intersected coordinates
		push @$intsct, $type;
	}
	return $intsct;
}

