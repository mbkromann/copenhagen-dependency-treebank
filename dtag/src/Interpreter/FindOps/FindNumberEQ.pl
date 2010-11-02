package FindNumberEQ;
@FindNumberEQ::ISA = qw(FindOp);

use overload
    '""' => \& print;

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$self->{'args'}[0]->unbound($unbound);
	$self->{'args'}[1]->unbound($unbound);
	return $unbound;
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift || {};

	my $val1 = $self->{'args'}[0]->nvalue($graph, $bindings, $bind);
	my $val2 = $self->{'args'}[1]->nvalue($graph, $bindings, $bind);
	return defined($val1) && defined($val2) && ($val1 == $val2);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return "(" . 
		($self->utf8print() 
			? $args->[0] . ($self->{'neg'} ? " ≠ " : " = ") . $args->[1]
			: $args->[0] . ($self->{'neg'} ? " != " : " == ") . $args->[1])
		. ")";
}
