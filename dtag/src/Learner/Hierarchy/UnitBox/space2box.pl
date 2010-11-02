# A plane list has the form: [$plane, ...] where $plane = [$dimension,
# $min, $max]

sub space2box {
	my $self = shift;
	my $planes = shift;
	my $box = shift || $self->rootbox();

	# Apply planes one by one
	foreach my $plane (@$planes) {
		my ($dim, $min, $max) = @$plane;
		my $range = $box->[$dim];
		$range->[0] = max($range->[0], $min);
		$range->[1] = min($range->[1], $max);
		return undef if ($range->[0] >= $range->[1]);
	}

	# Return box
	return $box;
}

