sub split_data {
	my $self = shift;
	my $data = shift;
	my $dim = shift;
	my $type = shift;

	# Initialize array with data
	my $included = [];
	my $excluded = [];

	# Sort data into arrays
	foreach my $d (@$data) {
		my $dtype = $d->[$dim];
		my $supers = $lexicon->{'super'}{$d->[$dim]} || [];
		if (grep {$_ eq $type} ($dtype, @$supers)) {
			push @$included, $d;
		} else {
			push @$excluded, $d;
		}
	}

	# Return hash with new data
	return [$included, $excluded];
}

