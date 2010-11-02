# Find candidates for hash entries that match all keys 
sub match_keys {
	my $self = shift;
	my $hash = shift;
	my $keys = shift;

	# Check whether all keys exist
	my $defined = shift || [];
	foreach my $uckey (@$keys) {
		my $key = lc($uckey);
		if (defined($key)) {
			return [] if (! exists $hash->{$key});
			push @$defined, $key;
		}
	}

	# Sort keys according to number of matches
	my @sorted = sort {
		scalar(@{$hash->{$a}}) <=>
			scalar(@{$hash->{$b}})
	} @$defined;

	# Intersect all lists
	my $intsct = $hash->{$sorted[0]};
	shift(@sorted);
	foreach my $key (@sorted) {
		$intsct = intsct($intsct, $hash->{$key});
	}

	# Return intersection
	return $intsct;
}
