sub match_pattern {
	my $self = shift;
	my $graph = shift;
	my $nodes = shift;
	my $pattern = shift;
	my $prefix = shift || [];
	my $matches = shift || [];
	my $imin = shift || 0;
	my $imax = shift;
	$imax = defined($imax) ? min($imax, $#$nodes) : $#$nodes;

	#print "match_pattern: " . 
	#	DTAG::Interpreter::dumper(["nodes", $nodes, "pattern",
	#$pattern, "prefix", $prefix, "matches", $matches, "imin", $imin,
	#	"imax", $imax]) . "\n";

	# Succeed if pattern is empty
	if (! @$pattern) {
		push @$matches, $prefix;
		return $matches;
	}

	# Try each node as starting point
	for (my $i = $imin; $i <= $imax; ++$i) {
		# Test whether starting point matches
		my $node1 = $graph->node($nodes->[$i]);
		if ((lc($node1->input()) eq lc($pattern->[0]))
				|| ($pattern->[0] =~ /^\/.*\/$/ 
					&& &{$self->var('regexps')->{$pattern->[0]} ||
					$dummysub}($node1->input()))) {
			# Starting point matches
			if ($#$pattern == 0) {
				# Remaining pattern is empty
				push @$matches, [@$prefix, $nodes->[$i]];
			} elsif (defined($pattern->[1])) {
				# Next pattern is not a gap: check that next node is adjacent
				my $nextnode = $graph->next_noncomment_node($nodes->[$i] + 1);
				# print "pattern: next=$nextnode i=$i nodes[i]+1=" .
				#	($nodes->[$i] + 1) . 
				#	"nodes[i+1]=" . $nodes->[$i+1] . "\n";
				if ($i < $#$nodes && $nodes->[$i+1] == $nextnode) {
					$self->match_pattern($graph, $nodes, 
						[@$pattern[1..$#$pattern]],
						[@$prefix, $nodes->[$i]],
						$matches,
						$i + 1,
						$i + 1);
				}	
			} else {
				# Next pattern is a gap: skip any number of words
				$self->match_pattern($graph, $nodes, 
					[@$pattern[2..$#$pattern]],
					[@$prefix, $nodes->[$i]],
					$matches,
					$i + 1,
					$#$nodes);
			}
		}
	}

	# Return matches
	return $matches;
}

