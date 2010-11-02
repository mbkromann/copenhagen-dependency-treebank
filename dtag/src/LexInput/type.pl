sub type {
	my $name = $_[0];
	my $type = Type->new(@_);
	my $lexicon = lexicon();

	# Register type name in types-hash, if name is defined
	if (defined($name)) {
		# Print warning if type already exists with that name
		warn("Warning: type $name already declared; old definition deleted.")
			if ((exists $lexicon->{'ntypes'}{$name})
				|| (exists $lexicon->{'types'}{$name}));

		# Register type
		$lexicon->{'ntypes'}{$name} = $type;
	}

	# Return type
	return $type;
}
