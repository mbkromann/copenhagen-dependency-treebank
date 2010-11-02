sub cmd_patch {
	my $self = shift;
	my $graph = shift;
	my $key = shift;
	my $difffile = shift;

	# print "patch $key : $difffile\n";

	sub usage {
		print "Usage: use one of the two following patch commands:\n";
		print '    patch $difffile          (for graphs)', "\n";
		print '    patch -$key $difffile    (for alignments)', "\n";
	}

	# Check that diff-file exists
	my $diff;
	if (! -f "$difffile" ) {
		print "ERROR: Cannot open diff-file $difffile for reading\n";
		usage();
		return 1;
	}

	if (UNIVERSAL::isa($graph, 'DTAG::Graph')) {
		# Patch graph: Check arguments
		if (defined($key)) {
			print "ERROR: Key arguments cannot be used with graphs.\n";
			usage();
			return 1;
		}

		# Read diff file
		$diff = $self->read_tagdiff($graph, $difffile);	

		# Apply patch
		$self->cmd_patch_graph($graph, $diff);
		print "patched current graph with diff-file $difffile\n";
	} else {
		# Patch alignment: Check arguments
		if (! defined($key)) {
			print "ERROR: You need to supply a key argument.\n";
			usage();
			return 1;
		}

		# Read diff file
		my $keygraph = $graph->graph($key);
		if (! defined($keygraph)) {
			print "ERROR: Cannot find graph in aligment associated with key $key.\n";
		}
		$diff = $self->read_tagdiff($keygraph, $difffile);	

		#print "diff:\n";
		#foreach my $d (@$diff) {
		#	print join("\n", join(" ", @{$d->[0]}), 
		#		join("\n", map {"a: " . $_->xml($keygraph)} @{$d->[1]}),
		#		"---", join("\n", map {"b: " . $_->xml($keygraph)} @{$d->[2]}), "==="), "\n";
		#}

		# Patch alignment
		$self->cmd_patch_graph($keygraph, $diff);
		$self->cmd_patch_alignment($graph, $keygraph, $diff, $key);
		print "patched current alignment with diff-file $difffile for key \"" .  ($key || "") . "\"\n";
	}

	return 1;
}

