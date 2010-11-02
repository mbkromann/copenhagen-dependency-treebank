sub cmd_save_malt {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Calculate line numbers
	my $lines = [];
	my $line = 0;
	my $rightboundaries = {};
	my $rightboundary = 0;
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		my $input = $node->input();


		# Process node
		if (! $node->comment()) {
			$lines->[$i] = ++$line;

			# Update right boundary
			foreach my $e (@{$node->in()}) {
				my $n = $e->out();
				$rightboundary = $n if ($n > $rightboundary);
			}
			foreach my $e (@{$node->out()}) {
				my $n = $e->in();
				$rightboundary = $n if ($n > $rightboundary);
			}
		}
		
		print "i=$i rb=$rightboundary\n";
		# Check for boundary
		if ($input =~ /^<\/s>/ || $rightboundary <= $i) {
			print "\n";
			$line = 0;
			$rightboundaries->{$i} = 1;
		}
	}

	# Open MALT file
	open("MALT", "> $file") 
		|| return error("cannot open tag-file for writing: $file");

	# Write MALT file line by line
	my $pos = $graph->layout($self, 'pos') || sub {return 0};
	foreach (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);

		# Process non-comment nodes
		my $input = $node->input() || "??";
		if (! $node->comment()) {
			my $tag = $node->var($self->var('malt_feature_tag') || "msd") 
				|| "??";

			# Find first top dependency edge
			my $edges = [grep {! &$pos($graph, $_)} @{$node->in()}];
			my ($head, $type) = (0, "HEAD");
			if (scalar(@$edges) >= 1) {
				# One primary parent 
				my $edge = $edges->[0];
				$type = $edge->type() || "??";
				$head = $lines->[$edge->out()] || "??";

				# More than one primary parent
				if (scalar(@$edges) > 1) {
					warning("node $i: more than one primary head");
				}
			}

			# Print head and type
			print MALT "$input\t$tag\t$head\t$type\n";
		} 
		
		if ($rightboundaries->{$i}) {
			print MALT "\n";
		}
	}

	# Close file
	close("MALT");
	print "saved malt-file $file\n" if (! $self->quiet());

	# Return
	return 1;
}

