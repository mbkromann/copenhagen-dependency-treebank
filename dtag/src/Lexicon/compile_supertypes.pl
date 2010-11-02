sub compile_supertypes {
	my $self = shift;

	# Delete super type hash
	foreach my $type (keys(%{$self->{'super'}})) {
		delete $self->{'super'}{$type};
	}

	# Process all type names in lexicon
	foreach my $type (@{$self->types() || []}) {
		# Get super types for type
		$self->compile_supertype($type); 
	}
}

sub compile_supertype {
	my $self = shift;
	my $type = shift;

	# Fail if type is already compiled
	return 1 if ($self->{'super'}{$type});

	# Retrieve type, and fail if type does not exist
	my $typeobj = $self->get_type($type);
	return 0 if (! $typeobj);

	# Retrieve super types of $type
	my $supers = $typeobj->get_super();
	my $list = [];
	my $exists;
	foreach my $s (@$supers) {
		# Ensure that each super type has been compiled
		if (! $self->{'super'}->{$s}) {
			$exists = $self->compile_supertype($s) 
		} else {
			$exists = 1;
		}

		# Add super type and its super types to list
		push @$list, $s, @{$self->{'super'}->{$s}}
			if ($exists);
	}

	# Save super types of $type
	$self->{'super'}{$type} = [uniq(@$list)];

	# Return with success
	return 1;
}


