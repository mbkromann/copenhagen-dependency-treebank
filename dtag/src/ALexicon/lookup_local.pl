sub lookup_local {
	my $self = shift;
	my $out = shift;
	my $type = shift;
	my $in = shift;

	# Find out and in candidates for match
	my $outcand = $self->match_keys($self->out(), $out);
	my $incand = $self->match_keys($self->in(), $in);

	# Intersect the two lists
	my $intsct = intsct($incand, $outcand);

	# Go through all alex on list in order to find match
	my $alexlist = $self->alex();
	foreach my $alex (@$intsct) {
		my $alexobj = $alexlist->[$alex];
		if ($alexobj->match($out, $type, $in)) {
			return $alexobj;
		}
	}

	# No match found
	return undef;
}

