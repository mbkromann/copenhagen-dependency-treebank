sub cmd_relhelpsearch {
	my $self = shift;
	my $graph = shift;
	my $regex = shift;

	# Find relation name
	my $relsetname = $graph->var("relset") || $self->var("relset");
	my $relset = $self->var("relsets")->{$relsetname} || undef;
	if (! defined($relset)) {
		error("Current graph has no associated relation set"
			. " (see relset command)");
		return 1;
	} 

	# Find all relations where a field matches regex
	my $match = sub {
		my $s = shift;
		$s =~ /$regex/;
	};

	# Find matching relations
	my $matches = [];
	foreach my $relation (sort(keys(%$relset))) {
		my $list = $relset->{$relation};
		if (ref($list) eq "ARRAY" && $list->[$REL_SNAME] eq $relation) {
			my $s = join("	", map {defined($_) ? $_ : ""} @$list);
			push @$matches, $relation 
				if (&$match($s));
		}
	}

	# Print matches
	print "\nMATCHES:\n"
		. join("", map {countname($relset, $_)}
			@$matches) . "\n";

	# Return
	return 1;
}

