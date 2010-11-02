sub compile_subtypes {
	my $self = shift;
	my $subtypes = {};

	# Clear subtype and submatch hash
	foreach my $t (keys(%{$self->{'sub'}})) {
		delete $self->{'sub'}{$t};
	}

	# Process all type names in lexicon
	my ($supers, $super);
	foreach my $type (@{$self->types() || []}) {
		# Get super types for type
		$supers = typeobj($type)->get_super();

		# Record type as subtype of each super type
		foreach my $super (@$supers) {
			# Ensure entry in $sub exists
			$subtypes->{$super} = [] if (! defined($subtypes->{$super}));

			# Add type to subtype list
			push @{$subtypes->{$super}}, $type;
		}
	}

	# Record subtype-list for each type
	my $typeobj;
	foreach my $type (keys(%$subtypes)) {
		$self->{'sub'}{$type} = $subtypes->{$type};
	}
}
