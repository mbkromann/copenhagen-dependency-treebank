# Specify tag feature
my $tag = "msd";

sub cmd_aparse {
	my $self = shift;
	my $graph = shift;
	my $afile = shift;
	my $scheme = shift;
	my $current_graph = $self->{'graph'};

	# Check scheme and correct scheme name
	if ($scheme =~ /^(da-en|da-es|da-it|da-de)$/) {
		$scheme =~ s/-/_/g;
		$scheme = "_" . $scheme;
	} else {
		error("unsupported scheme: $scheme\n");
		$scheme = "_da_en";
	}
	my $edgecmd = "process_edge$scheme";
	my $aedgecmd = "process_aedge$scheme";

	# Load alignment
	$graph->mtime(1);
	$self->cmd_load($graph, '-atag', $afile);
	my $alignment = $self->graph();

	# Check that alignment is loaded
	if (! UNIVERSAL::isa($alignment, 'DTAG::Alignment')) {
		error("invalid alignment graph: aborting aparse");
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

	# Process all alignment edges
	foreach my $e (@{$alignment->edges()}) {	
		&{\&$aedgecmd}($e, $alignment, $skey, $tkey, $graph);
	}

	# Process all dependency edges in source
	$source->do_edges(\&$edgecmd, $alignment, $skey, $tkey, $graph);
	
	# Postprocess graph
	for (my $n = 0; $n < $graph->size(); ++$n) {
		post_process($graph, $n) if (! $graph->node($n)->comment());

	}

	# Calculate possible dependencies for node with no dependencies
	#for (my $n = 0; $n < $graph->size(); ++$n) {
	#	post_process_dlabels($graph, $alignment, $skey, $tkey, $n) 
	#		if (!  $graph->node($n)->comment());
	#}

	# Return to original graph
	$self->{'graph'} = $current_graph;
	$self->cmd_return();

	# Return
	return 1;
}

sub process_aedge {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	# Debug
	print "Language pair $skey-$tkey unsupported\n";
}

sub my_edge_add {
	my $graph = shift;
	my $edge = shift;
	my $style = shift;
	# $style = "blue" if (! defined($style));

	# Set edge style
	if ($style) {
		my $node = $graph->node($edge->in());
		$node->var('estyles', "$style:" . $edge->type()) if ($node);
	}

	# Add edge
	$graph->edge_add($edge)
		if ($edge->in() ne $edge->out());
}

sub process_edge {
	my $e = shift;
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $graph = shift;

	print "Language pair $skey-$tkey unsupported\n";
}

sub find_head {
	my $graph = shift;
	my $nodes = shift;

	# Find all dependents of all nodes
	my $hash = {};
	foreach my $n (@$nodes) {
		my $node = $graph->node($n);
		next() if (! $node);
		my $out = $node->out() || [];
		map {$hash->{$_->in()} = 1} @$out;
	}

	# Find all nodes in $nodes that are not dependents
	my @roots = grep {($hash->{$_} || 0) != 1} @$nodes;

	# Return head if unique
	return (scalar(@roots) == 1) ? $roots[0] : undef;
}


sub src2target {
	my $alignment = shift;
	my $skey = shift;
	my $tkey = shift;
	my $snode = shift;

	my @tnodes = ();
	foreach my $aedge (grep {$_->type() ne "pnct"} @{$alignment->node($skey, $snode)}) {
		# Find source and target nodes
		my ($source, $target) = (undef, undef);
		if ($aedge->inkey() eq $tkey) {
			$source = $aedge->outArray();
			$target = $aedge->inArray();
		} elsif ($aedge->outkey() eq $tkey) {
			$source = $aedge->inArray();
			$target = $aedge->outArray();
		}

		# Save target nodes if $source and $target are defined
		if (defined($source) && defined($target)) {
			push @tnodes, @$target;
		}
	}

	# Return unique target node or undef
	return [@tnodes];
}

sub post_process {
	my $graph = shift;
	my $n = shift;
	my $node = $graph->node($n);

	# Return if node does not exist
	return if (! $node);

	# Return if node has a single governor
	my @govs = sort {$a->in() <=> $b->in()} 
		grep {$_->type !~ /\[/} @{$node->in()};
	return if (scalar(@govs) == 1);

	# Find dependent for unanalyzed comma
	my $maxloop = 50;
	if ($node->input() eq ",") {
		my $prev = $n - 1;
		while ($graph->node($prev) 
				&& scalar(@{$graph->node($prev)->in()})
				&& max($graph->node($prev)->in()->[0]->out(),
					map {$_->in()}
						@{$graph->node($prev)->out()}) < $n
				&& $maxloop) {
			$prev = $graph->node($prev)->in()->[0]->out();
			-- $maxloop;
		}
		if ($graph->node($prev) && ! $graph->node($prev)->comment()) {
			my_edge_add($graph, Edge->new($n, $prev, "pnct"));
		}
		return;
	}

	

	# Add filler subject to verbal complex
}

sub post_process_dlabels {
	my ($graph, $alignment, $skey, $tkey, $n) = @_; 
	
	# Find all siblings for this node
	my $tsibling = {};
	my $ssibling = {};
	foreach my $aedge (@{$alignment->node($tkey, $n)}) {
		map {$ssibling->{$_} = 1} @{$aedge->outArray()};
		map {$tsibling->{$_} = 1} @{$aedge->inArray()};
	}
	#$graph->node($n)->var('ssibling', join("|", sort(keys(%$ssibling))));
	#$graph->node($n)->var('tsibling', join("|", sort(keys(%$tsibling))));
	
	# Find edge types for all siblings in source graph
	my $sgraph = $alignment->graph($skey);
	my $sdeps = {};
	foreach my $snode (keys(%$ssibling)) {
		map {$sdeps->{$_->type()} = 1} @{$sgraph->node($snode)->in()};
	}
	$graph->node($n)->var('sdeps', join("|", sort(keys(%$sdeps))));

	# Find edge types for all siblings in target graph

	# Show set difference of edge types
}
