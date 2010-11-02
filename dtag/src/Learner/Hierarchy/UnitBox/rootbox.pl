sub rootbox {
	my $self = shift;
	
	# Create unit box
	my $dim = $self->dimension();
	my $box = [];
	for (my $i = 1; $i <= $dim; ++$i) {
		push @$box, [0, 1];
	}

	# Return unit box
	return $box;
}
