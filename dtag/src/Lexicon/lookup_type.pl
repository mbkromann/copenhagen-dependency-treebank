sub lookup_type {
	# Enter parameters
	my $self = shift;
	my $input = shift;
	my $typename = shift;
	my $type = typeobj($typename);
	my $list = shift || [];
	my $phon = shift || [];
	my $name = shift || $type->get_name(); 

	# Split type's phon-list into stem transformation and
	# concatenative morpheme, and find transformed stem.
	my ($sphon, $cphon) = $self->phon_split(@{$type->var('phon') || []});
	my $tstem = $self->phon2str(@$phon, @$sphon);

	# Input must match transformed stem plus some root; otherwise
	# just return
	my $match = 0;
	foreach my $root (@{$type->var('_roots') || []}) {
		my $str = $tstem . $root;
		if ($str eq substr($input, 0, length($str))) {
			$match = 1;
			last;
		}
	}
	return if (! $match);

	# Add type itself to list of matches if it matches $input
	my $str = $self->phon2str(@$phon, @$sphon, @$cphon);
	if ($str eq substr($input, 0, length($str))) {
		push @$list, [$str, $name];
	}
	
	# Proceed recursively with all transformed types
	my $trans = $type->var('trans');
	foreach my $t (sort(keys(%$trans))) {
		$self->lookup_type($input, $trans->{$t}, $list, 
			[@$phon, @$sphon, @$cphon], "$name|$t");
	}

	# Return list
	return $list;
}
