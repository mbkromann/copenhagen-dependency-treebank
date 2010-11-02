sub cmd_diff {
	my $self = shift;
	my $graph = shift;
	my $file = shift || $graph->{'diff_file'};

	# Get position subroutine
	my $pos = $graph->layout($self, 'pos') || sub {return 0};

	# Set diff file in graph
	$graph->{'diff_file'} = $file;

	# Load file with comparison analysis (using a few tricks to avoid
	# closing $graph)
	my $graphid = $self->{'graph'};
	$self->cmd_load(DTAG::Graph->new($self), undef, $file);
	my $graph2 = pop(@{$self->{'graphs'}});
	$self->{'graph'} = $graphid;

	# Delete all in-edges marked as 'diff' in $graph
	$graph->do_edges(
		sub {
			$_[1]->edge_del($_[0]) 
				if ($_[0]->var('diff'));
		},
		$graph);

	# Add edges in $graph2 to $graph
	$graph2->do_edges(
		sub {
			$_[0]->var('diff', 1);
			$_[0]->var('ignore', 1);
			$_[1]->edge_add($_[0]);
		},
		$graph);

	# Issue style commands
	$self->do('style plus -graph -arclabel -color red -arc -color red');
	$self->do('style minus -graph -arclabel -color red -arc -color red');
	$self->do('layout -graph -pos $e->var("diff")');
	$self->do('layout -graph -estyles [$G->diffplus($e) ? "plus" : 0, $G->diffminus($e) ? "minus" : 0]');

	my ($proposed50, $correct50) = (0,0);
	my $labels50 = {};

	# Compare graphs and print precision and recall
	if (! $self->quiet()) {
		my $stats = $self->compare_graphs($graph, $pos);

		# Print file names
		printf "gold-standard=%s\ndiff-file=%s\n",
			$graph->file(), $graph2->file();
		my $printf = "%-8s%8s%9s%8s%10s%10s%12s\n";
		printf $printf,
			"LABEL", "GOLD", "PROPOSED", "CORRECT", "PRECISION", "RECALL", "F-SCORE";
		printf $printf,
			"", "A1", "A2", "AGREED", "", "", "AGREEMENT";
		my $sep = sprintf $printf,
			"-----", "----", "--------", "-------", "---------", "------", "---------";
		print $sep;

		# Print statistics 
		my $print_total = 0;
		my $print_total1 = 0;
		foreach my $label ((sort {(($stats->{$b}[0]||0)+($stats->{$b}[1]||0))
		                <=> (($stats->{$a}[0]||0) + ($stats->{$a}[1]||0))
			|| $a cmp $b} keys(%$stats)), 'TOTAL', 'TOTAL1') {
			# Skip TOTAL the first time
			if ($label eq 'TOTAL') {
				if ($print_total) {
					print $sep;
				} else {
					$print_total = 1;
					next();
				}
			} elsif ($label eq 'TOTAL1') {
				if (! $print_total1) {
					$print_total1 = 1;
					next();
				}
			}
			
			# Find counts
			my ($total, $proposed, $correct, $correct_unlbl) = 
				($stats->{$label}[0] || 0, $stats->{$label}[1] || 0,
				$stats->{$label}[2] || 0, $stats->{$label}[3] || 0);
			
			# Print counts
			printf $printf,
				$label,
				$total, $proposed, $correct, 
				sprintf("%.1f", 100 * $correct / max(1, $proposed)), 
				sprintf("%.1f", 100 * $correct / max(1, $total)), 
				sprintf("%.1f", 200 * ($correct / max(1, $proposed)) 
					* ($correct / max(1, $total)) 
					/ max(0.00001, ($correct / max(1, $proposed) 
							+ $correct / max(1, $total))));

			# Calculate precision>0.5 totals
			if ($correct / max(1, $proposed) > 0.5 && $label !~ /^TOTAL/ && $total >= 5) {
				$correct50 += $correct;
				$proposed50 += $proposed;
				$labels50->{$label} = 1;
			}
		}

		# Print unlabelled total scores
		my ($total, $proposed, $correct, $correct_unlbl) = 
			($stats->{'TOTAL'}[0] || 0, $stats->{'TOTAL'}[1] || 0,
			$stats->{'TOTAL'}[2] || 0, $stats->{'TOTAL'}[3] || 0);
		printf $printf,
			"nolabel",
			$total, $proposed, $correct_unlbl, 
			sprintf("%.1f", 100 * $correct_unlbl / max(1, $proposed)), 
			sprintf("%.1f", 100 * $correct_unlbl / max(1, $total)), 
			sprintf("%.1f", 200 * ($correct_unlbl / max(1, $proposed)) 
				* ($correct_unlbl / max(1, $total)) 
				/ max(0.00001, ($correct_unlbl / max(1, $proposed) 
						+ $correct_unlbl / max(1, $total))));

		# Print unlabelled total primary scores
		($total, $proposed, $correct, $correct_unlbl) = 
			($stats->{'TOTAL1'}[0] || 0, $stats->{'TOTAL1'}[1] || 0,
			$stats->{'TOTAL1'}[2] || 0, $stats->{'TOTAL1'}[3] || 0);
		printf $printf,
			"nolabel1",
			$total, $proposed, $correct_unlbl, 
			sprintf("%.1f", 100 * $correct_unlbl / max(1, $proposed)), 
			sprintf("%.1f", 100 * $correct_unlbl / max(1, $total)), 
			sprintf("%.1f", 200 * ($correct_unlbl / max(1, $proposed)) 
				* ($correct_unlbl / max(1, $total)) 
				/ max(0.00001, ($correct_unlbl / max(1, $proposed) 
						+ $correct_unlbl / max(1, $total))));

		# Print relative annotation time compared to manual
		print "\n\nRelative annotation time for automatic relative to manual annotation\n    = ((GOLD-CORRECT) + 2*(PROPOSED-CORRECT))/GOLD = "
			. sprintf("%.1f%%\n", 100 * (
				($total - $correct) 
					+ 2 * ($proposed - $correct)) / max(1, $total));

		# Print relative annotation time compared to manual
		print "\nRelative annotation time for automatic with precision > 50% relative to manual annotation\n";
		print "using labels: " . join(" ", sort(keys(%$labels50))) . "\n";
		print "    = ((GOLD-PROPOSED50) + 2*(PROPOSED50-CORRECT50))/GOLD = "
			. sprintf("%.1f%%\n", 100 * (
				($total - $proposed50
					+ 2 * ($proposed50 - $correct50)) / max(1, $total)));
	}

	# Update graph
	$self->cmd_return() if (! $self->abort());

	# Return
	return 1;
}

sub compare_graphs {
	my ($self, $graph, $pos) = @_;

	# Calculate counts: [$gold, $proposed, $correct, $correct_unlabeled]
	my $stats = {'TOTAL' => [0, 0, 0, 0]};
	for (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		if (! $node->comment()) {
			# Process in-edges
			foreach my $edge (@{$node->in()}) {
				my $label = $edge->type();

				# Initialize counters
				$stats->{$label} = [0, 0, 0] 
					if (! exists $stats->{$label});

				# Determine whether edge is a primary dependency edge or not
				my $primary = ! &$pos($graph, $edge);
				
				if ($edge->var("diff")) {
					# Annotation: proposed
					$stats->{'TOTAL'}[1] ++;
					$stats->{'TOTAL1'}[1] ++ if ($primary);
					$stats->{$label}[1] ++;

					# Correct
					if (! $graph->diffminus($edge)) {
						$stats->{'TOTAL'}[2] ++;
						$stats->{'TOTAL1'}[2] ++ if ($primary);
						$stats->{$label}[2] ++;
					}

					# Correct unlabeled
					if (! $graph->diffminus($edge, 1)) {
						$stats->{'TOTAL'}[3] ++;
						$stats->{'TOTAL1'}[3] ++ if ($primary);
					}
				} else {
					# Gold-standard: total
					$stats->{'TOTAL'}[0] ++;
					$stats->{'TOTAL1'}[0] ++ if ($primary);
					$stats->{$label}[0] ++;
				}
			}
		}
	}

	# Return counts
	return $stats;
}

#	# Compare edges in graphs, node by node
#	my $n = max($graph1->size(), $graph2->size());
#	my ($nedges1, $nedges2, $nplus1, $nplus2) = (0, 0, 0, 0);
#	for (my $i = 0; $i < $n; ++$i) {
#		my $node1 = $graph1->node($i) || Node->new();
#		my $node2 = $graph2->node($i) || Node->new();
#		
#		# Find edges which only exist at one node, and print differences
#		my $plus1 = edge_setdiff($node1->in(), $node2->in(), "diff:");
#		my $plus2 = edge_setdiff($node2->in(), $node1->in(), "diff: del");
#
#		# Count edges
#		$nedges1 += scalar(@{$node1->in()});
#		$nedges2 += scalar(@{$node2->in()});
#		$nplus1  += scalar(@$plus1);
#		$nplus2  += scalar(@$plus2);
#
#		# Add edges in $graph1 to $graph2, marking them as "diff=1"
#		foreach my $e1 (@{$node1->in() || []}) {
#			my $clone = $e1->clone();
#			$clone->var('diff', '1');
#			$graph2->edge_add($clone);
#		}
#
#		# Abort if requested
#		last() if ($self->abort());
#	}
#	# Print status
#	printf "statistics: edges1=%i edges2=%i plus1=%i plus2=%i diff=%.4g%%\n",
#		$nedges1, $nedges2, $nplus1, $nplus2, 
#		100 * ($nplus1 + $nplus2) / (($nedges1 + $nedges2) || 1); 
#
