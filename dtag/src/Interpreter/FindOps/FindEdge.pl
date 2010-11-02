package FindEdge;
@FindEdge::ISA = qw(FindOp);

sub vars {
	return [0,1];
}

sub _pprint {
	my $self = shift;
	my $var1 = $self->{'args'}[0];
	my $var2 = $self->{'args'}[1];
	my $relpattern = $self->{'args'}[2];
	return "(" . $var1 . " " . $relpattern->pprint() . " " . $var2 .  ")";
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;
	my $var1 = $self->{'args'}[0];
	my $var2 = $self->{'args'}[1];
	my $keygraph = $self->keygraph($graph, $bindings, $var1, $var2);
	
	# Nodes
	my $in = $self->varbind($bindings, $bind, $var1);
	my $out = $self->varbind($bindings, $bind, $var2);
	my $relpattern = $self->{'args'}[2];

	# Check whether there exists an edge from node $in to $out with
	# type $etype
	my $node = $keygraph->node($in);
	return 0 if (! $node);
	return 1 
		if (grep {$_->out() == $out 
			&& $relpattern->match($keygraph, $_->type())} (@{$node->in()}));
	return 0;
}

sub next { 
    my $self = shift;
    my $graph = shift;
    my $bindings = shift;
    my $bind = shift;
    my $var = shift;

	my $var1 = $self->{'args'}[0];
	my $var2 = $self->{'args'}[1];
	my $keygraph = $self->keygraph($graph, $bindings, $var1, $var2);

	# Exit if constraint is negated
	return undef if ($self->{'neg'});

	# Find suggested in and out node
	my $in = $self->varbind($bindings, $bind, $var1);
	my $out = $self->varbind($bindings, $bind, $var2);
	
	# Determine unbound variable
	my $relpattern = $self->{'args'}[2];
	if ($var eq $var2) {
		# Determine out-node from in-node: find in-node
		my $node = $keygraph->node($in);
		return 0 if (! $node);

		# Find matching edges
		my @edges = sort {$a->out() <=> $b->out()} 
			(grep {$relpattern->match($keygraph, $_->type()) 
				&& $_->out() >= $out}  
				@{$node->in()});

		# Set $var, if there is a match
		if (@edges) {
			$bind->{$var2} = $edges[0]->out();
			return 1;
		} else {
			return 0;
		}
	} elsif ($var eq $var1) {
		# Determine in-node from out-node: find out-node
		my $node = $keygraph->node($out);
		return 0 if (! $node);

		# Find matching edges
		my @edges = sort {$a->in() <=> $b->in()} 
			(grep {$relpattern->match($keygraph, $_->type()) 
					&& $_->in() >= $in}  
				@{$node->out()});

		# Set $var, if there is a match
		if (@edges) {
			$bind->{$var1} = $edges[0]->in();
			return 1;
		} else {
			return 0;
		}
	}
}

