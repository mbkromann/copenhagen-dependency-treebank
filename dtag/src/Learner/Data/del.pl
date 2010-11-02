# $self->del($datum, ...): delete outcomes from data multi-set

sub del {
	my $self = shift;
	my $data = $self->data();

	# Delete each given outcome
	foreach my $datum (@_) {
		# Find offset of first outcome that matches $outcome
		my $offset = scalar(@$data) - 1;
		while ($offset >= 0 && $data->{$offset} ne $datum) {
			++$offset;
		}

		# Delete outcome at offset, if offset is legal
		splice(@$data, $offset, 1)
			if ($offset >= 0);
	}

	# Return
	return $self;
}

