sub cmd_title {
	my $self = shift;
	my $graph = shift;
	my $text = shift;

	# Create title automatically, if requested
	if ($text =~ /^\s*-auto\s*$/) {
		# Create title automatically
		my $fname = $graph->file() || "UNTITLED";
		$text = $fname . " on " . `date` . "(offset "
			. $graph->offset() . ")";
	} 

	if ($text =~ /^\s*-off\s*$/) {
		$text = undef;
	}

	$graph->var('title', $text);
	print "title=" . ($graph->var('title') || "UNTITLED") . "\n";
	return 1;
}
