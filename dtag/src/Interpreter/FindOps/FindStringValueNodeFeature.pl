package FindStringValueNodeFeature;
@FindStringValueNodeFeature::ISA = qw(FindStringValue);

use overload
    '""' => \& pprint;

sub vars {
	return [1];
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my $node = $args->[0];
	my $feat = $args->[1];
	return $self->{'args'}[0]->pprint() . (defined($feat) ? "[" . $feat . "]" : "");
}

sub svalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Variables
	my $nodevar = $self->{'args'}[0];
	my $featvar = $self->{'args'}[1];
	#print "nodevar=$nodevar featvar=" . ($featvar || "") . "\n";
	return undef if (! defined($nodevar));

	# Find key graph
	my $keygraph = $self->keygraph($graph, $bindings, $nodevar);
	#print "keygraph=" . ($keygraph || "undef") . "\n";
	return undef if (! defined($keygraph));

	# Find node id and node
	my $nodeid = $nodevar->nvalue($graph, $bindings, $bind);
	return undef if (! defined($nodeid));

	# Find node
	my $node = $keygraph->node($nodeid);
	return undef if (! defined($node));

	# Find value
	my $val = defined($featvar)
		? $node->var($featvar)
		: $node->input();
	#print "$nodevar" . (defined($featvar) ? "[$featvar]" : "") 
	#	. " ($nodeid) = " . (defined($val) ? $val : "_undef") . "\n";
	return defined($val) ? "" . $val : undef;
}

sub unbound {
	my $self = shift;
	my $unbound = shift;
	return $self->{'args'}[0]->unbound($unbound);
}


