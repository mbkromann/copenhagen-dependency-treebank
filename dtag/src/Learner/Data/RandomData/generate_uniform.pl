sub generate_uniform {
	my $self = shift;
	my $dim = shift;

	# Generate uniformly distributed random vector
	my $x = [];
	for (my $i = 0; $i < $dim; ++$i) {
		push @$x, rand();
	}

	# Return random vector
	return $x;
}
