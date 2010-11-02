sub paradigm {
	my $self = shift;
	my $type = typeobj(shift);
	my $name = shift || ($type ? $type->get_name() : "???");
	my $phons = shift || [];
	my $paradigm = shift || {};

	# Return if $type does not exist
	return $paradigm if (! $type);

	# Print all phoneme / type pairs associated with type
	$phons = [@$phons, @{$type->var('phon') || []}];
	my $phoneme = $self->phon2str(@$phons);
	
	# Add word to paradigm
	if (UNIVERSAL::isa($paradigm->{$phoneme}, 'ARRAY')) {
		push @{$paradigm->{$phoneme}}, $name;
	} else {
		$paradigm->{$phoneme} = [$name];
	}

	# Proceed recursively with all transformed types
	my $trans = $type->var('trans') || {};
	foreach my $t (sort(keys(%$trans))) {
		my $ttype = $trans->{$t};
		$self->paradigm($ttype, $name . "|$t", $phons, $paradigm);
	}

	# Return string representation
	return $paradigm;
}

sub paradigm_string {
	my $self = shift;
	my $type = shift;

	# Retrieve paradigm
	my $paradigm = $self->paradigm($type);

	# Convert paradigm to string
	my $str = "";
	foreach my $phon (sort(keys(%$paradigm))) {
		$str .= sprintf('%-20s %s' . "\n", 
			$phon, 
			join(" ", @{$paradigm->{$phon}})); 
	}

	# Return
	return $str;
}
