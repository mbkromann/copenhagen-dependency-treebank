sub cmd_load_emalt {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Open tag file
	open("MALT", "< $file") 
		|| return error("cannot open MALT-file for reading: $file");
	
	# Read graph
	my $malt2node = {};
	my $line = 0;
	my $sent = 0;
	for (my $i = 0; $i < $graph->size(); ++$i) {
		my $node = $graph->node($i);
		my $input = $node->input();
		if (! $node->comment()) {
			++$line;
			$malt2node->{"$sent:$line"} = $i;
		} elsif ($input =~ /<\/s>/) {
			++$sent;
			$line = 0;
		}
	}

	# Read MALT file line by line
	my $pos = 0;
	$sent = 0;
    while (my $line = <MALT>) {
		# Ignore blank lines
        chomp($line);
		if (! $line) {
			++$sent;
			$pos = 0;
			next();
		}
		
		# Process MALT line
		++$pos;
		my ($input, $msd, $head, $type) = split(/	/, $line);

		# Check that nodes match
		my $in = $malt2node->{"$sent:$pos"};
		my $nodein = $graph->node($in);
        my $input2 = ($nodein ?  $nodein->input() : "") || "";
		if (($input2 || "") ne ($input || "")) {
			warning("non-matching input $sent:$pos: tag-node=$in ["
			. ($input2 || "undef") . "] malt-node=$pos ["
			. ($input || "undef") . "]");
		} else {
			# Create edge
			if ($head) {
				my $e = Edge->new();
				$e->in($in);
				$e->type($type);
				$e->out($malt2node->{"$sent:$head"});
				$graph->edge_add($e);
			}
		}

		# Abort if requested 
		last() if ($self->abort());
	}

	# Close MALT file
	close("MALT");
	$self->cmd_return($graph);
	return 1;
}
