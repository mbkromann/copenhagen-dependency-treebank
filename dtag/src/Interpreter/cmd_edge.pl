sub cmd_edge {
	my $self = shift;
	my $graph = shift;
	my $nodein = shift() + $graph->offset();
	my $etype = shift;
	my $nodeout = shift() + $graph->offset();

	# Split type into multiple types
	my $edgesplits = $self->var("edgesplits") || [];
	foreach my $edgesplit (@$edgesplits) {
		#print "edgesplit: $edgesplit etype1=$etype ";
		eval("\$etype =~ $edgesplit");
		#print "etype2=$etype\n";
	}

	# Test whether edge is primary, and delete old incoming primary
	# edges first, if requested
	if (($self->option("autodelete") || "") eq "on" || ($graph->var("autodelete") || "") eq "on") {
		if ($graph->is_dependent($etype)) {
			my $node = $graph->node($nodein);
			my $edges = [];
			push @$edges, @{$node->in()} if ($node);
			foreach my $e (@$edges) {
				if ($graph->is_dependent($e->type())) {
					inform("Autodeleting primary edge: " .  $e->as_string());
					$graph->edge_del($e);
				} 
			}
		}
	}

	# Add edge(s) and mark graph as modified
	foreach my $t (split(/\s+/, $etype)) {
		$graph->edge_add(Edge->new($nodein, $nodeout, $t))
			if ($t !~ /^\s*$/);
	}

	# Update graph as modified
	$graph->mtime(1);
	return 1;
}
