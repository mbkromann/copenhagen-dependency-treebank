sub cmd_edit {
	my $self = shift;
	my $graph = shift;
	my $noder = shift;
	my $varstr = shift;
	my $vars = $self->varparse($graph, $varstr, 1);

	# Apply offset
	my $node = defined($noder) ? $noder + $graph->offset() : undef;

	# Find node 
	my $N = $graph->node($node);

	# Errors: non-existent node, or comment node
	return error("Non-existent node: $noder") if (! $N);
	return error("Node $noder is a comment node.") if ($N->comment());

	# Set values for all given variable-value pairs
	foreach my $var (keys %$vars) {
		if (defined($vars->{$var})) {
			if ($var eq 'input') {
				$N->input($vars->{$var});
			} else {
				$N->var($var, $vars->{$var});
			}
		}
	}

	# Create variable editing string
	my $edit = "";
	my @keys = keys(%$vars);
	@keys = (keys(%{$graph->vars()}), 'input') if (! @keys);
	foreach my $var (@keys) {
		$edit .= "$var=" . (($var eq 'input' 
				? $N->varstr('_input') : $N->varstr($var)) || "") . " "
			if (! defined($vars->{$var}));
	}
	chomp($edit);

	# Edit and mark graph as modified
	if ($edit) {
		$self->nextcmd("edit $node $edit");
	} 
	$graph->mtime(1);

	# Return
	return 1;
}
