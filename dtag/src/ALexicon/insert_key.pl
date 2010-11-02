sub insert_key {
	my $self = shift;
	my $hash = shift;
	my $key = lc(shift);
	my $id = shift;
	my $fhash = shift;

	# Create array for key, if necessary
	my $idlist = (exists $hash->{$key}) ? $hash->{$key} : [];

	# Add id to array, sort it, and use it as new idlist
	if (! exists $fhash->{$key}) {
		# Create entry
		$hash->{$key} = [ sort($id, @$idlist) ];

		# Check whether entry should be added to list of function words
		$fhash->{$key} = 1 
			if (scalar(@{$hash->{$key}}) > $FUNCTIONWORD_MAXCOUNT);
	}
}

