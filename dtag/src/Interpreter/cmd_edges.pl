sub cmd_edges {
	my ($self, $graph, $noder) = @_;

	# Dependency graphs
	if (UNIVERSAL::isa($graph, 'DTAG::Graph') 
			&& defined($noder) && $noder =~ /^[0-9]+$/)  {
		my $node = $graph->node(($noder || 0) + $graph->offset());
		if (! $node) {
			return error("non-existent node $noder\n");
		} else {
			my @iedges = map {
					($_->in() - $graph->offset()) . " "
					. ($_->type()) . " "
					. ($_->out() - $graph->offset()) . "\n"} 
				@{$node->in()};
			my @oedges = map {
					($_->in() - $graph->offset()) . " "
					. ($_->type()) . " "
					. ($_->out() - $graph->offset()) . "\n"} 
				@{$node->out()};
			print "" . (@iedges ? "in:\n  " . join("  ", sort(@iedges))  : "")
				. (@oedges ? "out:\n  " . join("  ", sort(@oedges)) : "");
		}
	}

	# Alignment graphs
	if (UNIVERSAL::isa($graph, 'DTAG::Alignment') && defined($noder) 
			&& $noder =~ /^([a-z])?([0-9]+)$/)  {
		my ($key, $node) = ($1, $2);
		$key = "a" if (! $key);
		$node += $graph->offset($key);
		my @edges = map {
			my $e = $graph->edge($_); 
			($e ? 
				$e->outkey() . 
				print_anodes([map {$_ - $graph->offset($e->outkey())} @{$e->outArray()}]) 
				. ($e->type() ? " " . ($e->type()) . " " : " ") .
				$e->inkey() .
				print_anodes([map {$_ - $graph->offset($e->inkey())} @{$e->inArray()}])
				. "\n"
			: "?")} 
			@{$graph->node_edges($key, $node) || []};
		print join("", sort(@edges));
	}

	return 1;
}

sub print_anodes {
	my $list = shift;
	$list = [sort(@$list)];
	my $inrange = 0;
	my @newlist = ();
	for (my $i = 0; $i <= $#$list; ++$i) {
		if ($i > 0 && $i < $#$list 
				&& $list->[$i-1] + 1 == $list->[$i]
				&& $list->[$i] + 1 == $list->[$i+1]) {
			if ($newlist[$#newlist] ne "..") {
				push @newlist, "..";
			}
		} else {
			if ($i > 0 && $newlist[$#newlist] ne "..") {
				push @newlist, "+";
			}
			push @newlist, $list->[$i];
		}
	}
	return join("", @newlist);
}
