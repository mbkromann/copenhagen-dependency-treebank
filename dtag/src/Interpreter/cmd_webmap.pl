sub cmd_webmap {
	my $self = shift;
	my $graph = shift;
	my ($tagvar, $wikidir, $exdir, $termexcount, $excount, $mincount, $url) 
		= @_;

	$tagvar = 'msd' if (! defined($tagvar));
	$wikidir = 'treebank.dk/map' if (! defined($wikidir ));
	$exdir = $wikidir if (! defined($exdir ));
	$termexcount = 10 if (! defined($termexcount ));
	$excount = $termexcount if (! defined($excount));
	$mincount = 2 if (! defined($mincount));
	$url = ".." if (! defined($url));

	# Debug
	print 'usage: webmap $tagvar $wikidir $exampledir $terminalExampleCount $ExampleCount $MinimalCount'; 
	print "\n";
	print "language must be encoded in '_lang' feature\n\n";
	print "running: webmap $tagvar $wikidir $exdir $termexcount $excount $mincount $url\n";

	# Issue command
	$graph->wikidoc($tagvar, $wikidir, $exdir, $termexcount, $excount, 
		$mincount, $url);
}
