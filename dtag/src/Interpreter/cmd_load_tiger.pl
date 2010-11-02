my ($TIGER_COMMENT, $TIGER_NT, $TIGER_T) = (0, 1, 2);

sub cmd_load_tiger {
	my $self = shift;
	my $graph = shift;
	my $file = shift;

	# Close current graph, if unmodified
	$self->cmd_load_closegraph($graph);

	# Create new graph
	$graph = DTAG::Graph->new($self);
	$graph->file($file);
	push @{$self->{'graphs'}}, $graph;
	$self->{'graph'} = scalar(@{$self->{'graphs'}}) - 1;

	# Inform user about action
	print "Importing data from TIGER XML file $file\n" 
		if (!  $self->quiet());

	# Head edge
	my $HEADEDGE = "--??";

	# Determine whether graph is a dependency graph
	my $vars = {};
	my $etypes = {};
	my $nodes = {};
	my $edges = [];
	my $terminals = {};
	my $nonterminals = {};
	my @newnodes = ();
	my $parents = {};
	my $heads = {};
	my $visited = {};
	my ($parent, $parentid, $ntid, $head, $headid);

	# Create parser object

		# Start tag handler
		my $handle_start = sub { 
			my $expat = shift;
			my $tag = lc(shift);

			# Sentence <s> tag: create comment node
			if ($tag eq 's') {
				@newnodes = ();
				$terminals = {};
				$nonterminals = {};
				$parents = {};
				$heads = {};
				$graph->node_add("", 
					xml2node($vars, $TIGER_COMMENT, 's', @_));
			}

			# Terminal <t> or non-terminal <nt> tag: record node
			if ($tag eq 'nt' || $tag eq 't') {
				# Create node
				my $node = xml2node($vars, 
					(($tag eq 't') ?  $TIGER_T : $TIGER_NT), 
					$tag, @_);

				# Register id of node and store id of nt-node for primary edges
				my $id = $node->var('id');
				if ($tag eq 't') {
					$terminals->{$id} = $node;
					push @newnodes, $node;
				} elsif ($tag eq 'nt') {
					$nonterminals->{$id} = $node;
				}
				$ntid = $id if ($tag eq 'nt');
			}

			# Edge <edge> tag or secondary edge <secedge> tag
			if ($tag eq 'edge' || $tag eq 'secedge') {
				my $edge = xml2edge($etypes, $ntid, @_);
				push @$edges, $edge;

				# Record parent and lexical head
				if ($tag eq 'edge') {
					# Record parent
					$parents->{$edge->in()} = $edge->out();

					# Record lexical head
					if ($edge->type() eq $HEADEDGE) {
						$heads->{$edge->out()} = $edge->in();
					}
				}
			}
		};

		# End tag handler
		my $handle_end = sub {
			my $expat = shift;
			my $tag = shift;

			# Sentence </s> tag: create comment node
			if ($tag =~ /^(s|S)$/) {
				# Add terminals and non-terminals to graph in top-down
				# left-right order
				while (@newnodes) {
					my $top = shift(@newnodes);
					my $id = $top->var('id') || "";

					# Skip node if it has already been added
					next() if ($nodes->{$id});

					# Process parent node first, if it exists
					if (defined($parentid = $parents->{$id})) {
						# Check that parent id refers to a real node,
						# and that it hasn't already been added to the graph,
						# and that the parent node does not correspond
						# to a terminal, if we are creating a
						# dependency graph
						if (defined($parent = $nonterminals->{$parentid})
								&& (! defined($nodes->{$parentid}))
								&& ! (defined($heads->{$parentid}))) {
							# Add parent and top node to list, and
							# process next node, if parent node has
							# not been visited before
							if (! $visited->{$parentid}) {
								$visited->{$parentid} = 1;
								unshift @newnodes, $parent, $top;
								next();
							}
						}
					}

					# Add top node to graph if it is non-terminal or
					# terminal without a $HEADEDGE parent
					if (defined($nonterminals->{$id})) {
						# Add any non-terminal node without $HEADEDGE
						# child to graph
						$nodes->{$id} = $graph->size();
						$graph->node_add("", $top);
					} else {
						# Terminal: copy features from $HEADEDGE parent first
						$parentid = $parents->{$id};
						if (defined($parentid) 
								&& ($heads->{$parentid} || "") eq $id) {
							# Copy features
							$parent = $nonterminals->{$parentid};
							foreach my $var (keys(%$vars)) {
								if (! defined($top->var($var))) {
									$top->var($var, $parent->var($var) || "");
								}
							}

							# Let parent id refer to non-terminal
							$nodes->{$parentid} = $graph->size();
						}

						# Add terminal to graph
						$nodes->{$id} = $graph->size();
						$graph->node_add("", $top);
					}
				}

				# Add edges to graph
				my $unresolved = [];
				foreach my $e (@$edges) {
					# Add edge to graph, or store it for later processing
					my $in = $nodes->{$e->in()};
					my $out = $nodes->{$e->out()};
					my $type = $e->type();
					if (defined($in) && defined($out)) {
						# Nodes exist: add edge to graph
						$e->in($in);
						$e->out($out);
						$graph->edge_add($e) 
							if ($in != $out);
					} else {
						# Nodes did not both exist: store as unresolved
						push @$unresolved, $e;
					}
				}
				$edges = $unresolved;

				# Create comment node
				$graph->node_add("", xml2node($vars, 0, '/s', @_));
			}
		};

	# Create XML parser
	my $xmlparser = $self->{'xmlparser'} 
		= new XML::Parser(
			'Handlers' =>
			{	'Start' => $handle_start, 
				'End' => $handle_end 
			});

	# Parse file
	open(XML, "<$file") 
		|| return error("cannot open TIGER XML file for reading: $file");
	eval('$xmlparser->parse(*XML)');
	print "errors = $@\n" if ($@);
	close(XML);

	# Insert names in $vars as permitted variable names
	foreach my $var (keys(%$vars)) {
		$graph->vars()->{$var} = undef;
	}

	# Warn about unresolved edges
	my $warn = "failed to resolved following edges:\n";
	foreach my $e (@$edges) {
		# Compute incoming and outgoing node
		$warn .= "\t" . ($e->out() || "?") . " --" . ($e->type() || "?")
			. "--> " . ($e->in() || "?") . "\n";
	}

	# Update graph
	$self->cmd_return();

	# Return
	return 1;
}


