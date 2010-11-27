package FindAlign;
@FindAlign::ISA = qw(FindOp);

sub _pprint {
	my $self = shift;
	my $outvars = $self->{'args'}[0];
	my $invars = $self->{'args'}[1];
	my $relpattern = $self->{'args'}[2];
	return "@" 
		. (defined($relpattern) ? $relpattern->pprint() : "")
		. "(" 
		. join(",", @$outvars)
		. ";"
		. join(",", @$invars)
		. ")";
}

sub unbound {
    # Return all unbound variables
    my $self = shift;
    my $unbound = shift;
    
	# Mark all unbound variables in hash $unbound
	my $args = $self->{'args'};
    map {$unbound->{$_} = 1} 
		(@{$args->[0]}, @{$args->[1]});

    # Return
    return $unbound;
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	#print "match: " 
	#	. join(" ", map {$_ . "=" . $bindings->{$_}} sort(keys(%$bindings))) 
	#	. " / "
	#	. join(" ", map {$_ . "=" . $bind->{$_}} sort(keys(%$bind))) . "\n";

	# Out- and in-variables
	my $outvars = [@{$self->{'args'}[0]}];
	my $invars = [@{$self->{'args'}[1]}];
	my $outfullmatch = $outvars->[0] eq "!" ? shift(@$outvars) : 0;
	my $infullmatch = $invars->[0] eq "!" ? shift(@$invars) : 0;

	# Find graphs and keys for nodes
	my $outgraph = $self->keygraph($graph, $bindings, @$outvars);
	my $ingraph = $self->keygraph($graph, $bindings, @$invars);
	my $outkey = $self->varkey($bindings, $outvars->[0]);
	my $inkey = $self->varkey($bindings, $invars->[0]);
	
	# Find potential edges (based on first out-node and outkey), 
	# and filter all potential edges
	my $out1 = $self->varbind($bindings, $bind, $outvars->[0]);
	my $edges = [];
	EDGE : foreach my $e (@{$graph->node_edges($outkey, $out1) || []}) {
		# Check edge
		my $edge = $graph->edge($e);
		next EDGE if (! defined($edge));

		# Check in- and outkey of edge
		next EDGE if ($edge->inkey() ne $inkey
			|| $edge->outkey() ne $outkey);

		# Check number of in- and out-nodes on the edge
		next EDGE if (($outfullmatch 
				&& scalar(@{$edge->outArray()}) != scalar(@$outvars)) ||
			($infullmatch 
				&& scalar(@{$edge->inArray()}) != scalar(@$invars)));

		# Check each outnode is unique and valid on edge
		my $counts = {};
		map {$counts->{$_} = 0} @{$edge->outArray()};
		foreach my $outvar (@$outvars) {
			# Skip if not on outedge, or if outnode is non-unique
			my $out = $self->varbind($bindings, $bind, $outvar);
			next EDGE if (! defined($counts->{$out}));
			next EDGE if ($counts->{$out}++);
		}

		# Check each innode is unique and valid on edge
		$counts = {};
		map {$counts->{$_} = 0} @{$edge->inArray()};
		foreach my $invar (@$invars) {
			# Skip if not on inedge, or if innode is non-unique
			my $in = $self->varbind($bindings, $bind, $invar);
			next EDGE if (! defined($counts->{$in}));
			next EDGE if ($counts->{$in}++);
		}

		# Edge matches, so constraint is satisfied
		push @$edges, $edge;
	}

	# Check that there is an edge whose type matches given relation condition
	my $relpattern = $self->{'args'}[2];
	foreach my $edge (@$edges) {
		return 1 if ((! defined($relpattern)) 
			|| $relpattern->match($graph, $edge->type()));
	}

	# Otherwise return 0
	return 0;
}

sub next { 
    my $self = shift;
    my $graph = shift;
    my $bindings = shift;
    my $bind = shift;
    my @vars = @_;

	#print "vars: " . join(" ", @vars) . "\n";
	# Exit if constraint is negated
	return undef if ($self->{'neg'});
	
	# Out- and in-variables
	my $outvars = [@{$self->{'args'}[0]}];
	my $invars = [@{$self->{'args'}[1]}];

	# Find graphs and keys for nodes
	my $outgraph = $self->keygraph($graph, $bindings, @$outvars);
	my $ingraph = $self->keygraph($graph, $bindings, @$invars);
	my $outkey = $self->varkey($bindings, $outvars->[0]);
	my $inkey = $self->varkey($bindings, $invars->[0]);

	# Convert invar and outvar lists to hash tables
	my $invarhash = {};
	my $outvarhash = {};
	map {$outvarhash->{$_} = 1} (@$outvars);
	map {$invarhash->{$_} = 1} (@$invars);

	#

	# Find earliest variable in @vars on edge, remove all variables
	# from @vars that are not after this variable
	my ($var1) = grep {($outvarhash->{$_} || $invarhash->{$_})
			&& ! defined($bind->{$_})}
		sort(keys(%$bindings));
	my $key1 = $var1 ? $self->varkey($bindings, $var1) : undef;
	while (@vars && ! $var1) {
		my $v = shift(@vars);
		($var1, $key1) = ($v, $outkey) if ($outvarhash->{$v});
		($var1, $key1) = ($v, $inkey) if ($invarhash->{$v});
	}

	# Find value of earliest variable in binding
	my $val1 = $self->varbind($bindings, $bind, $var1);

	# Find alignment edges containing the node
	my $edges = $graph->node_edges($key1, $val1);
	if (! @$edges) {
		#print "return: $var1/" . join(",", @vars) . " " . join(" ", map {$_ . "=" . $bind->{$_}} keys(%$bind)) . "\n";
		$bind->{$var1}++;
		foreach my $v (@vars) {
			$bind->{$v} = 0;
		}
		return 1;
	}

	# Record all possible in- and out-nodes on alignment edges
	# connected to $var1
	my $outvals = {};
	my $invals = $outkey eq $inkey ? $outvals : {};
	foreach my $e (@$edges) {
		# Get alignment edge
		my $edge = $graph->edge($e);
		next if (! defined($edge));

		# Record node ids on alignment edge
		map {$outvals->{$_} = 1} @{$edge->outArray()};
		map {$invals->{$_} = 1} @{$edge->inArray()};
	}

	# Sort values in $invals and $outvals
	my @insort = sort(keys(%$invals));
	my @outsort = sort(keys(%$outvals));

	# Update variables in @vars
	foreach my $var (@vars) {
		my $val = $bind->{$var};
		$bind->{$var} = nextInArray($val, @insort)
			if ($invarhash->{$var});
		$bind->{$var} = nextInArray($val, @outsort, 1e100)
			if ($outvarhash->{$var});
	}

	
	# Return
	return 1;
}

sub nextInArray {
	my $value = shift;
	foreach my $v (@_) {
		return $v if ($v >= $value);
	}
	return 1e100;
}




