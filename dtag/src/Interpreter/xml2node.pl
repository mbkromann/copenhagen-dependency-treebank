sub xml2node {
	# Create node
	my $vars = shift;
	my $type = shift;
	my $tag = shift;
	my $node = Node->new();

	# Compute string representation of XML tag and set feature-value pairs
	my @strings = ();
	my $word = "";
	while (@_) {
		my $feature = shift;
		my $value = shift;
		
		# Save feature-value pair, if defined
		if (defined($feature) && $feature eq 'word') {
			# Word features are stored as input
			$word = defined($value) ? $value : "";
		} elsif (defined($feature) && defined($value)) {
			# Other features are stored as variables 
			$node->var($feature, $value);
			push @strings, "$feature=\"$value\"";
			$vars->{$feature} = 1;
		}
	}

	# Set string of node and comment status
	if ($type == $TIGER_COMMENT) {
		$node->input(join(" ", "<$tag",  @strings) . ">");
		$node->comment(1);
	} elsif ($type == $TIGER_T) {
		$node->input($word);
	} elsif ($type == $TIGER_NT) {
		$node->input("");
	}

	# Return node
	return $node;
}

