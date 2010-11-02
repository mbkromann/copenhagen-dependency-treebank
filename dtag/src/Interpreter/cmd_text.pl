sub cmd_text {
	my $self = shift;
	my $graph = shift;
	my $i1 = shift;
	my $i2 = shift;
	my $digits = shift;
	$digits = (defined($digits) && $digits);
	my $unicode = 1;

	# Ensure i2 and i2 are defined
	$i1 = "=0" if (! defined($i1));
	$i2 = "=" . ($graph->size()-1) if (! defined($i2));

	# Print text
	print $graph->words($graph->pos2apos($i1), $graph->pos2apos($i2), " ",
		$digits, $unicode)
		. "\n";

	# Return	
	return 1;	
}
