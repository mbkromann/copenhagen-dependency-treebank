sub cmd_errordefs {
	my ($self, $graph, $errorspec) = @_;
	
	my $errordefs = $graph->errordefs();
	foreach my $type ("node", "edge") {
		# Find matching errors
		my @matches = ();
		foreach my $e (@{$errordefs->{'@' . $type}}) {
			push @matches, $e
				if ((! $errorspec) || $e =~ /^$errorspec$/);
		}

		# Print matching errors
		if (@matches) {
			print "Error definitions: $type\n";
			foreach my $e (@matches) {
				print "    $e: " . $errordefs->{$type}{$e}[2] . "\n";
			}
			print "\n";
		}
	}

	# Return
	return 1;
}
