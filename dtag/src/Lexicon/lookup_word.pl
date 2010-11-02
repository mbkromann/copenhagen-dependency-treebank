sub lookup_word {
	my $self = shift;
	my $input = shift;

	# Find lexemes matching beginning of input, and retrieve only
	# lexemes matching entire input
	my $list = [];
	foreach my $pair (@{$self->lookup($input)}) {
		push @$list, $pair->[1]
			if ($pair->[0] eq $input);
	}

	# Return
	return $list;
}


