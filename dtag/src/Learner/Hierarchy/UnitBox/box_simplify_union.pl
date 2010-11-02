sub box_simplify_union {
	my $self = shift;

	my @union = ();

	# Simplify union by removing empty boxes or boxes contained in
	# other boxes
	foreach my $box (@_) {
		# Skip empty boxes
		next() if (! defined($box));

		# Check that box isn't contained in any other union
		my $skip = 0;
		for (my $i = 0; $i < scalar(@union); ++$i) {
			if ($self->box_contains($union[$i], $box)) {
				$skip = 1;
				last();
			}
		}
		next() if ($skip);

		# Remove everything from union contained in $box
		for (my $i = 0; $i < scalar(@union); ++$i) {
			if ($self->box_contains($box, $union[$i])) {
				# Remove box from union
				splice(@union, $i, 1);
				--$i;
			}
		}

		# Add box to union
		push @union, $box;
	}

	# Return simplified union
	return @union;
}
