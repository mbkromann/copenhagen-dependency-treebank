sub cmd_example {
	my $self = shift;
	my $graph = shift;
	my $spec = shift;
	my $nopos = shift;
	$spec = "" if (! defined($spec));


	# Create new graph
	my $offset = -1;
	my $add = 0;
	if ($spec =~ /^-add\s+/) {
		$add = 1;
		$spec =~ s/^-add\s+//g;
		my $node = Node->new();
		$node->input("\n");
		$graph->node_add($graph->size(), $node);
		$graph->offset($graph->size());
	} else {
		$self->do("new");
		$graph = $self->graph();
	}
	if ($spec =~ s/^-nopos\s+//) {
		$nopos = 1;
	}

	# Create graph from specification
	my $quiet = $self->quiet();
	$self->quiet(1);
	my $nodes = 0;
	my $edges = [];
	my $inaligns = [];
	my $features = 0;
	my $title = "";
	while (length($spec) > 0) {
		if ($spec =~ s/^-title="(.*)"\s*//) {
			# Title
			$title = $1;
		} elsif ($spec =~ s/^@([^()]*)\(([^,]+),([^,()]+)\)\s*//) {
			my $oset = $2;
			my $iset = $3;
			push @$inaligns, "inalign "
				. map_align_offset($2, -1)
				. " $1 " 
				. map_align_offset($3, -1);
		} elsif ($spec =~ s/^(\S+)\s*//) {
			# Parse node specification
			my $nespec = $1;
			$nespec =~ /^([^<>]+)(<(.*)>)?$/;
			my $nodespec = $1;
			my $edgespec = defined($3) ? $3 : "";
			my $labels = [split(/\|/, $nodespec)];

			# Create node
			my $cmd = "node " . $labels->[0];
			for (my $i = 1; $i <= $#$labels; ++$i) {
				if ($i > $features) {
					$self->do("vars f$i");
					++$features;
				}
				$cmd .= " f$i=\"" . $labels->[$i] . "\"";
			}
			$self->do($cmd);
			++$nodes;

			# Parse edge specification
			foreach my $edge (split(/,/, $edgespec)) {
				$edge =~ /^([0-9]+):(.*)$/;
				my $e = "edge " . ($nodes - 1) . " $2 "
					. ($1 - 1);
				push @$edges, $e;
			}
		} else {
			# Ignore garbage tokens
			$spec =~ s/(\S*)//;
			warning("Couldn't parse $1");
			$spec =~ s/^\s+//;
		}
	}

	# Create edges
	foreach my $edge (@$edges) {
		$self->do($edge);
	}

	# Create inaligns
	foreach my $inalign (@$inaligns) {
		$self->do($inalign);
	}

	# Set layout of nodes
	my @features = sort(keys(%{$graph->vars()}));
	push @features, "_position" if (! $nopos);
	my $cmd = "layout -graph -vars /stream:.*/|" 
		. join("|", @features);
	$self->do("inline 0 #$title") if ($title ne "");
	$self->do($cmd);
	if ($title ne "") {
		if ($add) {	
			$self->do("node x");
			my $titlenode = $graph->node($graph->size()-1);
			$titlenode->input('    "' . $title . '"');
		} else {
			$graph->var("title", $title);
		}
	}

	# Update display
	$self->cmd_return();
	$self->quiet($quiet);
	$graph->offset(0);

	# Return
	return 1;
}
