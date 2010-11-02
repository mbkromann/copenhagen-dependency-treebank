sub random {
	my $self = shift;
	my $distribution = shift;
	my $n = shift || 10;
	my $seed = shift;

	# Seed random generator, if requested
	srand($seed) if ($seed);

	# Generate random outcomes
	my $data = DTAG::Learner::Data->new();
	my $observations = $data->{'data'} = [];
	my $outcomes = $data->{'outcomes'} = [];
	for(my $i = 0; $i < $n; ++$i) {
		# Select box randomly
		my $rand = rand();
		my $sum = 0;
		my $k = -1;
		do {
			$sum += $distribution->[++$k][0];
		} until ($sum > $rand);
		my $box = $distribution->[$k][1];

		# Generate uniformly distributed random vector in
		# $distribution->[k] until it lies outside
		# $distribution->[0..k-1]
		my $x = [];
		my $inside = 0;
		while (! $inside) {
			# Generate random number in box
			foreach (my $i = 0; $i < $self->dimension(); ++$i) {
				$x->[$i] = $box->[$i][0] 
					+ rand() * ($box->[$i][1] - $box->[$i][0]);
			}

			# Check that number lies outside $distribution->[0..k-1]
			$inside = 1;
			foreach (my $i = 0; $i < $k; ++$i) {
				if ($self->box_inside($distribution->[$i][1], $x)) {
					$inside = 0;
					last();
				}
			}
		}

		# Add observation to data set
		$data->add($x);
	}

	# Return
	return $data;
}
