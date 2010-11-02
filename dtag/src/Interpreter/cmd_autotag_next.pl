sub cmd_autotag_next {
	my $self = shift;
	my $graph = shift;
	my $value = shift;

	# Find autotag variable
	my $var = $graph->var('autotagvar');
	if (! defined($var)) {
		error("Autotagging is turned off. Please use \"autotag \$var \$files\" to turn it on");
		return;
	}

	# Set current value if value is defined
	my $node;
	my $pos = $graph->var('autotagpos');
	if (defined($value)) {
		# Find current position
		$node = $graph->node($pos);

		# Determine if user specified value or value id
		if (defined($node)) {
			# Process shortcuts
			if ($value =~ /\#/) {
				my $shortcuts = $graph->var('autotagshortcuts');
				for (my $i = 0; $i <= $#$shortcuts; ++$i) {
					my $shortcut = $shortcuts->[$i];
					$value =~ s/\#$i(?![0-9])/$shortcut/g;
				}
			} 

			# Set new value
			if (defined($value)) {
				$node->var($var, $value);
				$self->cmd_autotag_addkeys($node->input(), $value, $var); 
			}
		}
	}

	# Find next untagged node
	my $matches = $graph->var('autotagmatches');
	for (my $i = $pos + 1; $i < $graph->size(); ++$i) {
		$node = $graph->node($i);
		if (defined($node) && ! $node->comment()
			&& (! defined($matches) || $matches->{$i})) {
			$pos = $i;
			last;
		}
	}

	# Exit if we reached end of graph
	if ($pos >= $graph->size() || ! defined($node)) {
		inform("Autotagger reached end of graph");
		return;
	}

	# Save position	
	$graph->var('autotagpos', $pos);
	
	# Lookup word in lexicon, and add in most frequent first order
	my $shortcuts = [];
	my $hash = $self->cmd_autotag_lookup($node->input(), $var);
	my $hicount = 0;
	foreach my $value (sort {$hash->{$b} <=> $hash->{$a}} keys(%$hash)) {
		$hicount = $hash->{$value}
			if ($hash->{$value} > $hicount);
		if ($hash->{$value} > $hicount / 20 && $#$shortcuts < 15) {
			push @$shortcuts, $value
				if (! grep {$value eq $_} @$shortcuts);
		}
	}

	# Find default shortcut (lemma or input by default)
	my $defaultshortcutfield = $graph->var('autotagshortcut_default') ||
		["lemma", "_input"];
	foreach my $field (@$defaultshortcutfield) {
		my $value = ($field eq "_input") ? $node->input() : $node->var($field);
		if (defined($value)) {
			push @$shortcuts, $value
				if (! grep {$value eq $_} @$shortcuts);
			last;
		}
	}

	# Left and right context parameters
	my $wordsep = "\n       ";
	my $maxchars = 60;
	my $maxcount = 5;

	# Find left and right context
	my $lcontext = [];
	for (my $i = $pos - 1; $i >= 0 && scalar(@$lcontext) < $maxcount; --$i) {
		if (! $graph->node($i)->comment()) {
			unshift @$lcontext, $i;
		}
	}

	# Find right context
	my $rcontext = [];
	for (my $i = $pos + 1; $i < $graph->size() 
			&& scalar(@$rcontext) < $maxcount; ++$i) {
		my $node = $graph->node($i);
	    if (defined($node) && ! $graph->node($i)->comment()) {
			push @$rcontext, $i;
		}
	}

	# Print out context
	foreach my $cpos (@$lcontext, $pos, @$rcontext) {
		autotag_next_print_node($graph, $cpos, $var, 
			($cpos == $pos) ? "*" : " ");
	}

	# Print out shortcuts
	$graph->var('autotagshortcuts', $shortcuts);
	for (my $i = 0; $i <= $#$shortcuts; ++$i) {
		print "#$i: " . $shortcuts->[$i] . "\n";
	}
}

sub autotag_next_print_node {
	my ($graph, $pos, $var, $mark) = @_;
	my $offset = $graph->offset();
	my $node = $graph->node($pos);
	printf("%1s % 5s: %-20s %s\n", 
		$mark, 
		($offset > 0 && $pos >= $offset ?  "+" : "") . ($pos - $offset),
		$node->input() || "", $var . "=" . ($node->var($var) || ""));
}

sub autotag_setpos {
	my ($self, $graph, $pos, $prev) = @_;
	my $offset = $graph->offset();
	$pos = $offset + $pos;
	$graph->var('autotagpos', $prev ? $pos - 1 : $pos);
}
