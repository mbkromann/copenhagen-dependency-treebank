sub cmd_del {
	my $self = shift;
	my $graph = shift;
	my $nodeinr = shift;
	my $etype = shift;
	my $nodeoutr = shift;
	my $called_as_edel = shift;

	# Check that nodeblocking is not activated
	if ($graph->{'block_nodedel'} && ! $called_as_edel) {
		print "WARNING: Node deletion turned off: no edges deleted\n";
		print "Please use \"edel <node>\" or \"edel <node> <label> <node>\"\n";
		print "when deleting in-edges. Node deletion can be turned on/off\n";
		print "with \"del -on\" / \"del -off\"\n";
		return 1;
		#$self->cmd_edel($graph, $nodeinr);
	}

	# Delete range if relevant
	if ($nodeinr =~ /^([+-]?[0-9]+)\.\.([+-]?[0-9]+)/) {
		my $first = $1;
		my $last = $2;
		if ($first < $last) {
			for (my $i = $last; $i >= $first; --$i) {
				$self->cmd_del($graph, $i);
			}
		}
		return 1;
	}


	# Apply offset
	my $nodein = defined($nodeinr) ? $nodeinr + $graph->offset() : undef;
	my $nodeout = defined($nodeoutr) ? $nodeoutr + $graph->offset() : undef;

	# Check that $nodein is valid
	my $nin  = $graph->node($nodein);
	my $nout = $graph->node($nodeout);
	return error("Non-existent node: $nodeinr") 
		if ((! defined($nodein)) || (! ref($nin)));

	# Delete in-edges in $nodein (and out-edges, if $nodein is deleted)
	my @edges = defined($etype) 
		? @{$nin->in()} 
		: (@{$nin->in()}, @{$nin->out()});
	foreach my $e (@edges) {
		# Delete edge if it matches description
		if (($e->in() == $nodein || ($e->out() == $nodein)) && 
			((! defined($etype)) 
				|| (($e->type() eq $etype)
					&& ($e->out() == $nodeout)))) {
			$graph->edge_del($e) 
		}
	}

	# Delete node, if requested
	if ((! $graph->{'block_nodedel'}) && ! defined($etype)) {
		# Delete node
		splice(@{$graph->nodes()}, $nodein, 1);
		my $id = $nin->var("id");
		$graph->compile_ids();

		# Update edges in nodes at or after $nodein
		for (my $i = $nodein; $i < $graph->size(); ++$i) {
			my $n = $graph->node($i);

			# Process in-edges
			foreach my $e (@{$n->in()}) {
				if ($e->in() > $e->out()) {
					$e->in($e->in() - 1);
					$e->out($e->out() - 1) if ($e->out() >= $nodein);
				}
			}

			# Process out-edges
			foreach my $e (@{$n->out()}) {
				if ($e->out() > $e->in()) {
					$e->out($e->out() - 1);
					$e->in($e->in() - 1) if ($e->in() >= $nodein);
				}
			}
		}
	}

	# Mark graph as modified
    $graph->mtime(1);

	# Return
	return 1;
}

