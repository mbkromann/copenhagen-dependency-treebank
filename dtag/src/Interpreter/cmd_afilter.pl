# Remove a dependent whƣch isn't source-linked to any target node? 
my $remove_unlinked_dependent = 0;

# Remove a dependent where no transitive source parent is linked to a
# target node? 
my $remove_unlinked_transitive_parent = 1;

# Remove a dependent which is source-linked to another target node,
# but not the governor?
my $remove_doubly_linked = 1;

# Specify tag feature
sub cmd_afilter {
	my $self = shift;
	my $graph = shift;
	my $afile = shift;
	my $current_graph = $self->{'graph'};

	# Load alignment
	$graph->mtime(1);
	$self->cmd_load($graph, '-atag', $afile);
	my $alignment = $self->graph();

	# Check that alignment is loaded
	if (! UNIVERSAL::isa($alignment, 'DTAG::Alignment')) {
		error("invalid alignment graph: aborting afilter");
		return 1;
	}

	# Find source graph, source key, and target key
	my ($tkey, $skey, $source);
	my $graphfile = $graph->file();
	$graphfile =~ s/^.*\/([^\/]*)$/$1/g;
	foreach my $key (keys(%{$alignment->graphs()})) {
		my $keyfile = $alignment->graph($key)->file();
		$keyfile =~ s/^.*\/([^\/]*)$/$1/g;
		print "graph=$graphfile key=$keyfile\n";
		if ($graphfile eq $keyfile) {
			# Found target
			$tkey = $key;
		} else {
			# Found source
			$skey = $key;
			$source = $alignment->graph($skey);
		}
	}

	# Exit if source and target key not found
	if (! $skey || ! $tkey) {
		error("target graph does not match any graph in alignment");
		return 1;
	}
	print "source=". $source->file() . " target=" . $graph->file() . "\n";

	# Process all dependency edges in target
	$graph->do_edges(\&filter_edge, $alignment, $source, $graph, $skey, $tkey);
	
	# Return to original graph
	$self->{'graph'} = $current_graph;
	$self->cmd_return();

	# Return
	return 1;
}

sub filter_edge {
	my $e = shift;
	my $alignment = shift;
	my $source = shift;
	my $target = shift;
	my $skey = shift;
	my $tkey = shift;
	#print "e=$e alignment=$alignment source=$source target=$target skey=$skey tkey=$tkey\n";

	# Find nodes linked to dependent, and the linked parents
	if ($target->is_dependent($e)) {
		my $node = $tkey . $e->in();
		my $parent = $tkey . $e->out();
		my $nodes = find_linked_nodes($alignment, $node);
		my $parents = find_linked_parents($alignment, $source, $skey, $tkey, $node);

		# Determine what to do
		my $accept = 0;
		if ($nodes->{$parent}) {
			# Governor among linked nodes: accept
			$accept = 1;
		} elsif ($parents->{$parent}) {
			# Governor among linked parents: accept
			$accept = 1
		} elsif (! grep {$_ =~ /^$skey/} keys(%$nodes)) {
			# Dependent not linked to any source nodes
			$accept = ! $remove_unlinked_dependent;
		} elsif (grep {$_ =~ /^$tkey/} keys(%$parents)) {
			# Dependent has other linked parents, but governor not among them
			$accept = ! $remove_doubly_linked;
		} else {
			# Dependent has no transitive target parents: reject
			$accept = ! $remove_unlinked_transitive_parent;
		}

		# Delete dependency if not accepted
		$target->edge_del($e) if (! $accept);
	}
}

sub find_linked_parents {
	my $alignment = shift;
	my $srcgraph = shift;
	my $srckey = shift;
	my $tkey = shift;
	my $node = shift;
	my $parents = shift || {};

	# Find linked nodes
	my $nodes = find_linked_nodes($alignment, $node);

	# Find linked parents 
	foreach my $n (keys(%$nodes)) {
		my $nkey = substr($n, 0, 1);
		my $nid = substr($n, 1);
		if ($nkey eq $srckey) {
			my $snode = $srcgraph->node($nid);
			foreach my $edge (@{$snode->in()}) {
				if ($srcgraph->is_dependent($edge)) {
					find_linked_nodes($alignment, $nkey .  $edge->out(), 
						$parents);
				}
			}
		}
	}

	# If no target nodes among linked parents, take transitive parents
	if (! grep {$_ =~ /^$tkey/} keys(%$parents)) {
		foreach my $p (keys(%$parents)) {
			find_linked_parents($alignment, $srcgraph, $srckey, $tkey, $p, $parents);
		}
	}

	# Return linked parents
	return $parents;
}

sub find_linked_nodes {
	my $alignment = shift;
	my $node = shift;
	my $nodes = shift || {};

	# Return if node has been visited already
	return $nodes if ($nodes->{$node});
	$nodes->{$node} = 1;

	# Otherwise find all alignment edges linked to node
	foreach my $aedge (@{$alignment->node($node)}) {
		foreach my $n (@{$aedge->inArray()}) {
			find_linked_nodes($alignment, $aedge->inkey() . $n, $nodes);
		}
		foreach my $n (@{$aedge->outArray()}) {
			find_linked_nodes($alignment, $aedge->outkey() . $n, $nodes);
		}
	}

	# Return
	return $nodes;
}


