sub compile {
	my $self = shift;

	# Retrieve hashes
	my $utypes = $self->{'utypes'};
	my $ntypes = $self->{'ntypes'};

	# Compile regular expressions in phonhash
	$self->compile_phonh();

	# Delete all new types from database
	while (my ($key, $value) = each(%$ntypes)) {
		# Find type and compile it
		delete $self->{'types'}{$key};
	}

	# Compile all new types in lexicon, and copy them into 'types'-hash
	while (my ($key, $value) = each(%$ntypes)) {
		# Find type and compile it
		$self->compile_type($value);
	}

	# Delete all types in the ntypes list
	$self->{'ntypes'} = {};

	# Compile subtypes, super types, and word counts
	$self->compile_subtypes();
	$self->compile_supertypes();
	#$self->compile_count();

	# Find undefined types

	# Print error message with undefined types
	if (%$utypes) {
		error("undefined types: " 
			. join(" ", sort(keys(%$utypes))));
	}

	# Clear cache
	$self->cache_clear();
}
