sub cmd_patch_graph {
	my $self = shift;
	my $graph = shift;
	my $diff = shift;
	my $oldoffset = $graph->offset();
	$graph->offset(0);
	
	# Process diff commands
	my $offset = 0;
	foreach my $spec (@$diff) {
		# Read command
		my ($cmd, $a, $b) = @$spec;
		my ($o, $a1, $a2, $b1, $b2) = @$cmd;

		# Delete nodes
		if ($o eq "c" || $o eq "d") {
			#print "delete nodes from " . ($a1+$offset) 
			#	. " to " . ($a2 + $offset) . "\n";
			my $o = $offset;
			for (my $i = $a2 - $a1 - 1; $i >= 0; --$i) {
				# Compare input
				my $pos = $i + $a1 + $o;
				my $n = $graph->node($pos);
				#print "    delete word $pos at index $i ("
				#	. $n->input() . "/" . $a->[$i]->input() . ")\n";

				# Check input
				if ($n->input() ne $a->[$i]->input()) {
					print "ERROR: Expected word " . $a->[$i]->input()
						. " but found word " . $n->input() . "\n";
				}
				
				# Delete node
				$self->cmd_del($graph, $pos);
				--$offset;
			}	
		} 
		
		# Add nodes
		if ($o eq "c" || $o eq "a") {
			#print "add nodes from $b1 to $b2\n"; 
			for (my $i = 0; $i < $b2-$b1; ++$i) {
				my $n = $graph->node_add($b1+$i, $b->[$i]);
				++$offset;
			}
		}
	}
}

