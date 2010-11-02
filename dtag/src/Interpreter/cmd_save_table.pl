sub cmd_save_table {
	my $self = shift;
	my $ograph = shift;
	my $file = shift || "";

	# Check whether table file name exists
    if (! $file) {
		error("cannot save: no name specified for table file");
		return 1;
	}

	# Create list of graph files to put into the table
	my @files = @_;
	@files = (undef) 
		if (! @files);

	# Global attributes
	my ($nodeattributes, $edgeattributes) = (["id"], ["in", "out"]);
	push @$nodeattributes, "file", "line";
	my $globalvars = {};

	# Process files
	my ($nodes, $edges, $nodecount) = ("", "", 1);
	foreach my $gfile (@files) {
		# Load graph for file
		my $graph;
		if (defined($gfile)) {
			# Load file
			$self->cmd_load($self->graph(), undef, $gfile);
			$graph = $self->graph();
			if (! defined($graph)) {
				error("Could not find graph file " . $gfile);
				next();
			}
		} else {
			# Undefined name: use old graph
			$graph = $ograph;
		}

		# Set file name
		$globalvars->{"node:file"} = $graph->file();

		# Create graph tables
		my ($nacount, $eacount) = (scalar(@$nodeattributes), scalar(@$edgeattributes));
		my ($gnodes, $gedges, $gnodecount) 
			= $graph->print_tables($nodecount, $nodeattributes, $edgeattributes, $globalvars);

		# Update tables
        $nodes = DTAG::Alignment::add_na_columns($nodes, scalar(@$nodeattributes) - $nacount);
		$edges = DTAG::Alignment::add_na_columns($edges, scalar(@$edgeattributes) - $eacount);
		$nodes .= $gnodes;
		$edges .= $gedges;
		$nodecount = $gnodecount;
		print $gfile . ": " . $nodecount . "\n";
	}

	# Add headers
	$nodes = "\"" . join("\"\t\"", @$nodeattributes) . "\"\n" . $nodes;
	$edges = "\"" . join("\"\t\"", @$edgeattributes) . "\"\n" . $edges;
							 
	# Open tag file
	open(XML, "> $file.nodes") 
		|| return error("cannot open table file for writing: $file.nodes");
	print XML $nodes;
	close(XML);
	open(XML, "> $file.edges") 
		|| return error("cannot open table file for writing: $file.edges");
	print XML $edges;
	close(XML);

	print "saved table files $file.nodes and $file.edges\n" 
		if (! $self->quiet());

	# Return
	return 1;
}

