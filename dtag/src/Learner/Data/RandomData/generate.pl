sub generate {
	my $self = shift;
	my $density = shift;
	my $dim = shift;
	my $n = shift || 0;
	my $seed = shift;

	# Seed random generator, if requested
	srand($seed) if ($seed);

	# Generate random outcomes
	my $data = $self->{'data'} = [];
	my $outcomes = $self->{'outcomes'} = [];
	my $i = 0;
	while ($i < $n) {
		# Generate random vector with uniform distribution
		my $x = $self->generate_uniform($dim);

		# Only include $x in the data set if density of $x > a random
		# number in [0,1]
		if (&$density($x) > rand()) {
			$self->add($x);
			++$i;
		}
	}

	# Return
	return $self;
}
