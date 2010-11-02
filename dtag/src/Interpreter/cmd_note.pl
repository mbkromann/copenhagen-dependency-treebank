sub cmd_note {
	my $self = shift;
	my $graph = shift;
	my $noder = shift;
	my $note = shift;

	# Check that graph is a dependency graph
	if (! UNIVERSAL::isa($graph, 'DTAG::Graph')) {
		error("ERROR: Notes not supported for alignments\n");
		return 1;
	}

	# Find absolute node
	my $node = defined($noder) ? $noder + $graph->offset() : undef;
	my $N = $graph->node($node);

	# Errors: non-existent node, or comment node
	return error("Non-existent node: $noder") if (! $N);
	return error("Node $noder is a comment node.") if ($N->comment());

	# Clean up note
	$note =~ s/"/&quot;/g;
	$note =~ s/</&lt;/g;
	$note =~ s/</&gt;/g;

	# Set values for all given variable-value pairs
	$graph->vars()->{'note'} = 1;
	$N->var("note", $note);
	$graph->mtime(1);

	# Return
	return 1;
}
