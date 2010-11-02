sub clone {
	my $self = shift;
	my $clone = ALex->new();

	# Copy self to clone
	for (my $i = 0; $i < scalar(@$self); ++$i) {
		$clone->[$i] = $self->[$i];
	}

	# Return clone
	return $clone;
}
