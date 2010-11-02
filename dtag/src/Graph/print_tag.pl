sub print_tag {
	my $graph = shift;
	
	# Write XML file line by line
	my $s = "";
	for (my $i = 0; $i < $graph->size(); ++ $i) {
		my $N = $graph->node($i);
		$s .= ($N->comment() 
				? ($N->input() . "\n")
				: ($N->xml($graph, 0 - $i) . "\n"));
	}

	# Write inalign edges as comments at the end of the file
	foreach my $inalign (sort(keys(%{$graph->{'inalign'}}))) {
		$s .= "<!--<inalign>" . $inalign . "</inalign>-->\n";
	}

	# Return
	return $s;
}

