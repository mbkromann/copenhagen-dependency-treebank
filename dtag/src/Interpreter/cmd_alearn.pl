sub cmd_alearn {
	my $self = shift;
	my $graph = shift;
	my $sublexfnames = shift;

	# Check that graph is an alignment
	if (! UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		error("current graph is not an alignment");
		return 1;
	}

	# Create new alignment lexicon
	my $alexicon = $graph->alexicon();
	if ($sublexfnames || ! $alexicon) {
		# Load sublexicons
		my $sublexicons = [];
		foreach my $fname (split(' ', $sublexfnames)) {
			my $sublexicon = DTAG::ALexicon->new();
			$sublexicon->load_alex($fname);
			push @$sublexicons, 
				$sublexicon;
		}

		# Create new alexicon and record it in graph
		$alexicon = DTAG::ALexicon->new();
		$alexicon->sublexicons($sublexicons);
		$graph->alexicon($alexicon);
	}

	# Train new lexicon
	$alexicon->untrain();
	$alexicon->train($graph);
	
	# Print learned lexicon
	#print $alexicon->write_alex();
}

