sub cmd_as_example {
	my $self = shift;
	my $graph = shift;
	my $varspec = shift || "";
	my $rangespec = shift || "=0..=" . $graph->size();

	# Only applies to dependency graphs
	if (! $graph->isa("DTAG::Graph")) {
		error("current graph is not a dependency graph");
		return 1;
	}

	# Process range specification
	my $range = {};
	my $offset = $graph->offset();
	while ($rangespec ne "") {
		if ($rangespec =~ s/^\s*([-+=]?)([0-9]+)\.\.([-+=]?)([0-9]+)\b//) {
			my $i1 = ($1 eq "=") ? $2 : $offset + "$1$2";
			my $i2 = ($3 eq "=") ? $4 : $offset + "$3$4";
			for (my $i = $i1; $i <= $i2; ++$i) {
				$range->{$i} = 1
					if ($i >= 0 && $i < $graph->size() 
						&& ! $graph->node($i)->comment())
			}
		} elsif ($rangespec =~ s/^\s*([-+=]?)([0-9]+)\b//) {
			my $i = ($1 eq "=") ? $2 : $offset + $2;
			$range->{$i} = 1
				if ($i >= 0 && $i < $graph->size() 
					&& ! $graph->node($i)->comment())
		} else {
			$rangespec =~ s/^\s+//g;
			$rangespec =~ s/^\S+//g;
		}
	}

	# Number nodes
	my $nodes = {};
	my $nodecnt = 0;
	foreach my $i (sort {$a <=> $b} keys(%$range)) {
		$nodes->{$i} = ++$nodecnt;
	}

	# Process nodes and in-edges
	my $s = "";
	my @vars = split(/\|/, $varspec);
	foreach my $i (sort {$a <=> $b} keys(%$range)) {
		# Process features
		my $node = $graph->node($i);
		if (! $node->comment()) {
			my @strings = ($node->input());
			foreach my $var (@vars) {
				push @strings, $node->svar($var);
			}
			$s .= join("|", @strings);

			# Process in-edges
			my @edges = ();
			foreach my $e (@{$node->in()}) {
				my $out = $nodes->{$e->out()};
				my $type = $e->type();
				push @edges, "$out:$type"
					if ($out);
			}
			$s .= "<" . join(",", @edges) . ">"
				if (@edges);
		}
		$s .= " ";
	}

	# Process inalignments
	my @alignments = sort {map_num($a) <=> map_num($b)}
		keys(%{$graph->var("inalign")});
	foreach my $align (@alignments) {
		my ($in, $out, $label) = split(/\s+/, $align);
		my $mapin = map_inalign($in, $nodes);
		my $mapout = map_inalign($out, $nodes);
		if (defined($mapin) && defined($mapout)) {
			$s .= "@" . $label . "($mapin,$mapout) ";
		}
	}

	# Print string
	print "\n" . $s . "\n\n";
}

sub map_inalign {
	my $spec = shift;
	my $nodes = shift;
	my $mapped = "";
	while (length($spec) > 0) {
		if ($spec =~ s/^([0-9]+)//) {
			my $mapnode = $nodes->{$1};
			return undef if (! defined($mapnode));
			$mapped .= $mapnode;
		} else {
			$spec =~ s/^([^0-9]+)//;
			$mapped .= $1;
		}
	}
	return $mapped;
}

sub map_num {
	my $s = shift;
	$s =~ /^([0-9]+)/;
	return $1 || 0;
}
