sub cmd_notes {
	my ($self, $graph) = @_;
	my $imin = $graph->var("imin");
	my $imax = $graph->var("imax");
	
	$imin = 0 if ($imin < 0);
	$imax = $graph->size() if ($imax < 0 || $imax > $graph->size());
	for (my $i = $imin; $i < $imax; ++$i) {
		my $note = ($graph->node($i)->var("note") || "") . "";
		$note =~ s/\&quot;/"/g;
		$note =~ s/\&lt;/</g;
		$note =~ s/\&gt;/>/g;

		print "NOTE[" . ($i - $graph->offset()) . "]: " . $note .  "\n\n"
			if ($note);
	}
	return 1;
}
