sub cmd_autoalign {
	my $self = shift;
	my $graph = shift;
	my $files = shift || "";
	
	# Check that $graph is an Alignment
	if (! UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
		error("no active alignment");
		return 1;
	}

	# Turn off autoaligner if argument is "-off"
	if ($files =~ /^\s*-off\s*$/) {
		$graph->var('autoalign', 0);
		$self->cmd_return();
		return 1;
	}

	# If first file argument is "-default" and an alexicon already
	# exists, then drop given files
	$files = ""
		if ($files =~ /^\s*-default\s+/ 
			&& ($graph->alexicon() || $self->var('alexicon')));

	# Save current graph
	my $currentgraph = $self->{'graph'};
	$graph->mtime(1);

	# Create new alignment lexicon
	my $alexicon = $graph->alexicon();
	my $viewer = $self->var('viewer');
	$self->var('viewer', 0);
	if ($files) {
		$alexicon = DTAG::ALexicon->new();
		$graph->alexicon($alexicon);
		$self->var('alexicon', $alexicon);
		foreach my $file (glob($files)) {
			# Load file
			if ($file =~ /.alex$/) {
				# Alignment lexicon
				my $sublexicon = $alexicon->new_sublexicon();
				$sublexicon->load_alex($file);
			} elsif ($file =~ /.atag$/) {
				# Alignment: load alignment
				$self->cmd_load($graph, '-atag', $file);
				my $alignment = $self->graph();
				$self->{'graph'} = $currentgraph;

				# Train new lexicon for alignment
				#my $sublexicon = $alexicon->new_sublexicon();
				#$sublexicon->train($alignment);
				$alexicon->train($alignment);
			}
		}
	} elsif ($graph->alexicon()) {
		# Use previous alignment lexicon
		$alexicon = $graph->alexicon();
		$graph->alexicon($alexicon);
		inform("Using previous alignment lexicon");
	} elsif ($self->var('alexicon')) {
		# Use previous alignment lexicon
		$alexicon = $self->var('alexicon');
		$graph->alexicon($alexicon);
		inform("Using previous alignment lexicon");
	} else {
		error("No alignment lexicon specified");
		return 1;
	}

	# Autoalign edges
	$graph->auto_offset();
	$alexicon->autoalign($graph);
	$self->var('viewer', $viewer);

	# Update graph
	$self->cmd_return();

	# Return
	return 1;
}
