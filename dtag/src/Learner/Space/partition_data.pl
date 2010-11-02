sub partition_data {
	my $self = shift;
	my $data = shift;
	my $dim = shift;
	my $types = shift;

	# Initialize array with data
	my $partition = {};
	foreach my $t (@$types) {
		$partition->{$t} = [];
	}

	# Sort data into array
	foreach my $d (@$data) {
		my $dtype = $d->[$dim];
		my $supers = $lexicon->{'super'}{$d->[$dim]} || [];
		foreach my $t (@$types) {
			if (grep {$_ eq $t} ($dtype, @$supers)) {
				push @{$partition->{$t}}, $d;
				last();
			}
		}
	}

	# Return hash with new data
	return $partition;
}

