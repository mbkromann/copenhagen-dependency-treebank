sub cmd_adiff {
	my $self = shift;
	my $graph = shift;
	my $files = shift;
	
	# Open individual graphs
	my @graphs = ();
	foreach my $file (split(/ +/, $files)) {
		print "opening $file\n";
		$self->cmd_load_atag($graph, $file);
		$graph = $self->graph();
		push @graphs, $graph;
	}

    # Create new alignment object and add it to DTAG's list of graphs
    my $align = DTAG::Alignment->new($self);
    push @{$self->{'graphs'}}, $align;
    $self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# Specify graphs in alignment
	my $translate = {};
	my $first = $graphs[0];
	my $n = scalar(@graphs);
	for (my $i = 0; $i < $n; ++$i) {
		if ($i == 0) {
			$translate->{"0a"} = "a";
			$translate->{"0b"} = "b";
			$align->add_graph("a", $first->graph("a"));
		} elsif ($i % 2 == 1) {
			$translate->{$i . "b"} = chr(97 + $i);
			$translate->{$i . "a"} = chr(97 + $i + 1);
		} else {
			$translate->{$i . "a"} = chr(97 + $i);
			$translate->{$i . "b"} = chr(97 + $i + 1);
		}
		$align->add_graph(chr(97 + $i + 1), 
			$first->graph(chr(97 + (($i + 1) % 2))));
	}

	# Translate edges
	my $edgetbl = {};
	for (my $i = 0; $i < scalar(@graphs); ++$i) {
		$graph = $graphs[$i];
		foreach my $e (@{$graph->edges()}) {
			# Create new edge
			my $enew = $e->clone();
			$enew->inkey($translate->{$i . $e->inkey()});
			$enew->outkey($translate->{$i . $e->outkey()});
			$enew->format(4);
			$enew->creator($i + 1);
			$align->add_edge($enew);

			# Add old edge to $edgetbl
			my $estr = $e->string();
			$edgetbl->{$estr} = [] if (ref($edgetbl->{$estr}) ne 'ARRAY');
			push @{$edgetbl->{$estr}}, 
				$enew;
		}
	}

	# Check whether edges differ
	my $statistics = [];
	for (my $i = 0; $i <= $n; ++$i) {
		$statistics->[$i] = [];
		for (my $j = 0; $j <= $n; ++$j) {
			$statistics->[$i][$j] = 0;
		}
	}
	foreach my $e (keys(%$edgetbl)) {
		my $elist = $edgetbl->{$e};

		# Calculate statistics
		my $count = scalar(@$elist);
		$statistics->[0][$count] += $count;
		$statistics->[0][0] += $count;
		foreach my $edge (@$elist) {
			$statistics->[$edge->creator()][$count] += 1;
			$statistics->[$edge->creator()][0] += 1;
		}

		# Mark edges not shared by all annotators
		if (scalar(@$elist) < $n) {
			foreach my $edge (@$elist) {
				$edge->format(1);
			}
		}
	}

	# Print statistics
	print "\nCOUNTS:\n\n";
	for (my $i = -1; $i <= $n; ++$i) {
		printf("%8s", "") if ($i < 0);
		printf("%8s", "TOTAL") if ($i == 0);
		printf("%8s", "ANN$i") if ($i > 0);

		for (my $j = 0; $j <= $n; ++$j) {
			printf "%8s", ($j == 0 ? "TOTAL" : "$j-AGR") if ($i < 0);
			printf "%8s", $statistics->[$i][$j] if ($i >= 0);
		}
		print "\n";
	}

	print "\nPERCENTAGES OF ROW TOTAL:\n\n";
	for (my $i = -1; $i <= $n; ++$i) {
		printf("%8s", "") if ($i < 0);
		printf("%8s", "TOTAL") if ($i == 0);
		printf("%8s", "ANN$i") if ($i > 0);

		for (my $j = 0; $j <= $n; ++$j) {
			printf "%8s", ($j == 0 ? "TOTAL" : "$j-AGR") if ($i < 0);
			printf("  % 3.2f", $statistics->[$i][$j]
				/ $statistics->[$i][0] * 100) if ($i >= 0);
		}
		print "\n";
	}


	# Update graph
	$self->cmd_return();

	# Return
	return 1;
}
