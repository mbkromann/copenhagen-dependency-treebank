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
	my $nodeid = $self->varbind($bindings, $bind, $nodevar);
	my $node = $graph->node($nodeid);
	my $value = defined($node) ? $node->var($feat) : "NA";
	$value = "" if (! defined($value));

	# Check for valid number
	if ($value =~ /^-?\d+\.?\d*$/) {
		return $value;
	} else {
		DTAG::Interpreter::warning("non-number in $nodeid" . "[$feat]: using 0 instead");
		return 0;
	}
}





