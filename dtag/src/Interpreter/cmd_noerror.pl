sub cmd_noerror {
	my $self = shift;
	my $graph = shift;
	my $noder = shift;
	my $error = shift;
	$error = "" if (! defined($error));

	# Apply offset
	my $node = defined($noder) ? $noder + $graph->offset() : undef;

	# Find node 
	my $N = $graph->node($node);

	# Errors: non-existent node, or comment node
	return error("Non-existent node: $noder") if (! $N);
	return error("Node $noder is a comment node.") if ($N->comment());

	# Set values for all given variable-value pairs
	$graph->vars()->{"_noerror"} = undef;
	$N->var("_noerror", ":" . $error . ":");
	$graph->mtime(1);

	# Return
	return 1;
}
