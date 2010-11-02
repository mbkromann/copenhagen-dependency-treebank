=item $graph->yields($yields, $node) = $yields

Compute yields hash $yields containing the yield of node $node and the
yield of all other nodes in the yield of $node. 

=cut

sub yields {
	my $self = shift;
	my $yields = shift;
	my $node = shift;

	# Save yields in graph, if undefined
	$yields = $self->var('yields', {})	
		if (! $yields);
	
	# Process all nodes
	if (! defined($node)) {
		for ($node = 0; $node < $self->size(); ++$node) {
			$self->yields($yields, $node);
		}
	} else {
		# Find node object
		my $nodeobj = $self->node($node);

		# Skip node if it is a comment, a filler, or undefined, or if
		# its yield is defined already
		return $yields if ((! $nodeobj) 
			|| $nodeobj->comment() 
			|| (! $nodeobj->input()) 
			|| defined($yields->{$node}));
		$yields->{$node} = [];

		# Calculate non-filler dependents
		my @yield = ();
		push @yield, [$node, $node]
			if (length($nodeobj->input() || "") > 0);
		my $out = $nodeobj->out();
		my $etypes = $self->etypes();
		foreach my $e (@$out) {
			# Test whether edge is a complement or an adjunct
			if ($self->is_dependent($e)) {
				# Find yield of dependent
				$self->yields($yields, $e->in());
				push @yield, @{$yields->{$e->in()} || []};
			}
		}

		# Save yield
		#$yields->{$node} = [$self->yield_simplify(@yield)];
		push @{$yields->{$node}}, 
			$self->yield_simplify(@yield);
	}
		
	# Return yields
	return $yields;
}


