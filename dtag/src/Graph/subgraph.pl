sub subgraph {
	my $self = shift;
	my $edge = shift;

	# Initialize subgraph
	my $subnodes = {};
	my $subedges = {};

	# Add in- and out-nodes to subgraph
	my $in = $edge->in();
	my $out = $edge->out();
	$subnodes->{$in} = 1;
	$subnodes->{$out} = 1;

	# Add all parents and grandparents of the in- and out-node
	my $maxupdist = 3;
	for (my $dist = 1; $dist < $maxupdist; ++$dist) {
		foreach my $node (keys(%$subnodes)) {
			if ($subnodes->{$node} == $dist) {
				map {
					my $nout = $_->out(); 
					$subnodes->{$nout} = $dist + 1
						if (! $subnodes->{$nout});
				} @{$self->node($node)->in()};
			}
		}
	}

	# Add all nodes at distance 4 or less
	my $maxdist = 4;
	for (my $dist = 1; $dist < $maxdist; ++$dist) {
		foreach my $node (keys(%$subnodes)) {
			if ($subnodes->{$node} == $dist) {
				map {
					my $nin = $_->in(); 
					$subnodes->{$nin} = $dist + 1
						if (! $subnodes->{$nin});
				} @{$self->node($node)->out()};
			}
		}
	}
	#print DTAG::Interpreter::dumper($subnodes), "\n";

	# Find all dependents of subnodes
	my $deps_edges = [];
	map { push @$deps_edges, @{$self->node($_)->out()} } 
		keys(%$subnodes);
	my $depnodes = [sort(map {$_->in()} @$deps_edges)];

	# Find first and last node in set
    my $subnodes_list = [sort(keys(%$subnodes))];
	my $min = $subnodes_list->[0];
	my $max = $subnodes_list->[$#$subnodes_list];

	# Add nodes to subgraph
	my $subgraph = DTAG::Graph->new($self->interpreter());
	my $positions = {};
	my $dots = 0;
	$dots = 1 if ($depnodes->[0] < $min);
	for (my $n = $min; $n <= $max; ++$n) {
		if ($subnodes->{$n}) {
			# Add dots to subgraph if necessary
			if ($dots) {
				my $dotsnode = Node->new();
				$dotsnode->input('...');
				$subgraph->node_add(undef, $dotsnode);
				$dots = 0;
			} 

			# Add subnode to subgraph
			$positions->{$n} = $subgraph->size();
			$subgraph->node_add(undef, $self->node($n)->copy());
		} elsif (! $self->node($n)->comment()) {
			$dots = 1;
		}
	}
	
	# Add dots node if dependents to right of subgraph
	if ($depnodes->[$#$depnodes] > $max) {
		my $dotsnode = Node->new();
		$dotsnode->input('...');
		$subgraph->node_add(undef, $dotsnode);
	}

	# Add edges to subgraph
	#print "Positions: ", DTAG::Interpreter::dumper($positions), "\n";
	foreach my $node (keys(%$subnodes)) {
		foreach my $e (@{$self->node($node)->in()}) {
			if (exists $positions->{$e->in()}
					&& exists $positions->{$e->out()}) {
				my $newe = $e->clone();
				$newe->in($positions->{$e->in()});
				$newe->out($positions->{$e->out()});
				$subgraph->edge_add($newe);
			}
		}
	}

	# Mark matches
	if (exists $positions->{$edge->in()} && 
			exists $positions->{$edge->out()}) {
		$subgraph->node($positions->{$edge->in()})->var('styles', 'match');
		$subgraph->node($positions->{$edge->out()})->var('styles', 'match');
		$subgraph->node($positions->{$edge->in()})->var('estyles', 
			'ematch:\Q' . $edge->type() . '\E');
	}

	# Set vars
	my $vars = $subgraph->vars($self->vars());
	$vars->{'estyles'} = undef;
	$vars->{'styles'} = undef;
	return $subgraph;
}
