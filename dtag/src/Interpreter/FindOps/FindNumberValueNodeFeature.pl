package FindNumberValueNodeFeature;
@FindNumberValueNodeFeature::ISA = qw(FindNumberValue);

sub vars {
	return [0];
}

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$unbound->{$self->{'args'}[0]} = 1;
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my $node = $args->[0];
	my $feat = $args->[1];
	return $self->{'args'}[0] . "[" . $feat . "]";
}

sub nvalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

   	# Variables
	my $nodevar = $self->{'args'}[0];
	my $feat = $self->{'args'}[1];

 	# Find key graph
    my $keygraph = $self->keygraph($graph, $bindings, $nodevar);
    return undef if (! defined($keygraph));

    # Find node id and node
    my $nodeid = $nodevar->nvalue($graph, $bindings, $bind);
    return undef if (! defined($nodeid));

    # Find node
    my $node = $keygraph->node($nodeid);
    return undef if (! defined($node));
	print "keygraph=$keygraph node=$node\n";

    # Find value
    my $value = defined($feat)
        ? $node->var($feat)
        : $node->input();
	$value = "" if (! defined($value));


	# Check for valid number
	if ($value =~ /^-?\d+\.?\d*$/) {
		return $value;
	} else {
		DTAG::Interpreter::warning("non-number in $nodeid" . "[$feat]: using 0 instead of " . ($value || "undef"));
		return 0;
	}
}

