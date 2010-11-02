my $node_check = 1;

sub cmd_align {
	my $self = shift;
	my $alignment = shift;
	my $from = shift;
	my $type = shift;
	my $to = shift;
	my $creator = shift || 0;
	my $node_check = defined($_[0]) ? shift : 1;
	my $lineno = shift || -1;

	# Find first two keys
	my ($key1, $key2) = sort(keys(%{$alignment->{'graphs'}}));

	# Create new alignment edge
	my $edge = AEdge->new();
	my ($outkey, $out) = parse_enodes($alignment, $from, $key1, $node_check);
	my ($inkey, $in) = parse_enodes($alignment, $to, $key2, $node_check);
	$edge->inkey($inkey);
	$edge->in($in);
	$edge->outkey($outkey);
	$edge->out($out);
	$edge->type($type || "");
	$edge->creator($creator);
	$edge->var("lineno", $lineno);
	
	# Add edge to alignment, if $edge is legal
	if (defined($inkey) && defined($outkey) && defined($out) && defined($in)) {
		$alignment->add_edge($edge);
	} else {
		error("illegal alignment edge specification");
	}

	# Return
	return 1;
}

sub parse_enodes {
	my $alignment = shift;
	my $enodes = shift;
	my $key = shift;
	my $node_check = shift;

	# Extract key
	if ($enodes =~ s/^([a-z])//) {
		$key = $1;

		# Fail if key does not exist
		if (! exists $alignment->{'graphs'}{$key}) {
			error("illegal alignment key $key");
			return (undef, undef);
		}
	}

	# Extract first node
	my @nodes = ();
	my $node1;
	if ($enodes =~ s/^(-?[0-9]+)//) {
		$node1 = check_node_rel($alignment, $key, $1, $node_check);
		push @nodes, $node1;
		return (undef, undef) if (! defined($node1));
	} else {
		return (undef, undef);
	}

	# Process remaining string
	while ($enodes) {
		if ($enodes =~ s/^\.\.([a-z])?(-?[0-9]+)//) {
			return (undef, undef) if (defined($1) && $1 ne $key);
			my $node2 = check_node_rel($alignment, $key, $2, $node_check);
			return (undef, undef) if (! defined($node2));
			for (my $i = $node1 + 1; $i <= $node2; ++$i) {
				push @nodes, $i
					if (defined(check_node($alignment, $key, $i, 0,
						$node_check)));
			}
			$node1 = $node2;
		} elsif ($enodes =~ s/^\+([a-z])?(-?[0-9]+)//) {
			return (undef, undef) if (defined($1) && $1 ne $key);
			$node1 = check_node_rel($alignment, $key, $2, $node_check);
			return (undef, undef) if (! defined($node1));
			push @nodes, $node1;
		} elsif ($enodes =~ s/^\s+//) {
		} else {
			error("ill-formed node range description from \"$enodes\"");
			return (undef, undef);
		}
	}

	# Return nodes and key
	return ($key, scalar(@nodes) == 1 ? $nodes[0] : [@nodes]);
}

sub check_node_rel {
	my $alignment = shift;
	my $key = shift;
	my $rel = shift;
	my $node_check = shift;

	my $node = check_node($alignment, $key, $alignment->rel2abs($key, $rel), 
		$node_check);

	# Check whether result is defined
	if (! defined($node)) {
		error("alignment edge refers to non-existent node $key$rel");
		return undef;
	}

	# Return node
	return $node;
}

sub check_node {
	my $alignment = shift;
	my $key = shift;
	my $node = shift;
	my $node_check = shift;

	# Return undef and print warning if node does not exist
	my $graph = $alignment->{'graphs'}->{$key};
	return undef  
		if (! $graph || ! $graph->node($node) 
			|| ($graph->node($node)->comment() && $node_check));

	# Return node
	return $node;
}


