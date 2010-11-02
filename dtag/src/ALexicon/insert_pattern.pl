sub insert_pattern {
	my $self = shift;
	my $hash = shift;
	my $pattern = shift;
	my $id = shift;
	my $fhash = shift;

	# Insert each defined key in hash tables
	foreach my $key (@$pattern) {
		if (! defined($key)) {
			# Do nothing
		} elsif ($key =~ /^\/.*\/$/) {
			# Insert regular expression
			$self->insert_regexp($hash, $key, $id);
		} else {
			# Insert word
			$self->insert_key($hash, $key, $id, $fhash);
		}
	}
}

