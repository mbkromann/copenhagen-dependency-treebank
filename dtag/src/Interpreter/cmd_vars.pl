sub cmd_vars {
	my $self = shift;
	my $graph = shift;
	my $varstr = shift;

	# Check printing
	my $print = 0;
	$print = 1 if ($varstr =~ s/^\+print\s*//);

	# Read off variables from input string
	while ($varstr) {
		if ($varstr =~ s/^-(\S+)\s*//) {
			# Delete variable
			delete $graph->vars()->{$1};
		} elsif ($varstr =~ s/^(\S+):(\S+)\s*//) {
			# Add variable and abbreviation
			$graph->vars()->{$1} = $2;
		} elsif ($varstr =~ s/^(\S+)\s*//) {
			# Add variable with no abbreviation
			$graph->vars()->{$1} = undef;
		} else {
			# Remove uninterpretable input until next blank
			$varstr =~ s/^\S+\s*//;
		}
	}

	# Convert each variable to printable string
	my @vars = ();
	foreach my $var (sort(keys %{$graph->vars()})) {
		my $abbrev = $graph->vars()->{$var};
		push @vars, $var . ($abbrev ? " [$abbrev]" : "");
	}

	# Print variables
	if (! $self->quiet() || $print) {
		print "variables: " . join(", ", @vars). "\n";
		print "current graph is " . ($graph->{'vars.sloppy'} ? "sloppy" : "strict" ) . " with respect to unseen variables\n";
	}

	return 1;
}
