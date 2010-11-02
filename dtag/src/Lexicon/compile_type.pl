sub compile_type {
	my $self = shift;
	my $type = shift;
	my $name = $type->get_name() || "";

	# Return if type is compiled already
	return if ($name && $self->{'types'}{$name});

	# Compile all super types
	foreach my $s (@{$type->get_super()}) {
		my $stype = $self->{'ntypes'}{$s};
		$self->compile_type($stype)
			if ($stype);
	}

	# Find root string and transformations
	my @phon = @{$type->var('phon') || []};
	my $trans = $type->var('trans') || {};

	# Find transformed roots of lexical item
	if (scalar(@phon)) {
		# Find dynamic type strings
		my @phons = ([@phon]);
		foreach my $t (keys(%$trans)) {
			my @tphon = @{$trans->{$t}->var('phon') || []};
			push @phons, ($trans->{$t}->var('phon') || []);
		}

		# Calculate roots
		my @roots = $self->phonroots(@phons);

		# Store roots in type
		$type->var('_roots', [@roots]);

		# Enter roots into lookup hash
		if ($name) {
			foreach my $r (@roots) {
				my $list = $self->get_root($r);
				$list = [] if (ref($list) ne "ARRAY");
				push @$list, $name;
				$self->set_root($r, $list);
			}
		}
	}

	# Compile all local transformation types
	$trans = $type->lvar('trans') || DTAG::LexInput::hash();
	foreach my $t (keys(%{$trans->plus() || {}})) {
		$self->compile_type($trans->plus()->{$t});
	}

	# Compile match-functions
	if ($type->lvar('_match') && $name) {
		foreach my $s (@{$type->get_super()}) {
			my $stype = $self->get_type($s);
			my $submatches = $stype->submatches();
			if (! grep {$_ eq $s} @$submatches) {
				push @$submatches, $name;
				$stype->submatches($submatches);
				$self->set_type($s, $stype);
			}
		}
	}

	# Store compiled type
	if ($name) {
		$self->set_type($name, $type);
	}
}
