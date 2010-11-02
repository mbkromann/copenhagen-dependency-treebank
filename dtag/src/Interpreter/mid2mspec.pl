sub mid2mspec {
	my $self = shift;
	my $match = shift;
	
	# Initialize variables
	my $matches = $self->{'matches'};
	my $file = undef;
	my $binding = undef;
	$match = 1 if ($match < 1);

	# Convert match index to file name and index
	my $i = 0;
	foreach my $f (sort(keys(%$matches))) {
		my $m = $matches->{$f};
		if ($i + scalar(@$m) < $match) {
			# Search next file
			$i += scalar(@$m);
		} else {
			# Return found match
			$file = $f;
			$binding = $m->[$match - $i - 1];
			last;
		}
	}

	# Return file and binding
	return ($file, $binding);
} 

