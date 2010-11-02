package FindNumberLT;
@FindNumberLT::ISA = qw(FindOp);

use overload
    '""' => \& pprint;

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

	my $arg0 = $self->{'args'}[0];
	my $val1 = $arg0->nvalue($graph, $bindings, $bind);
	my $val2 = $self->{'args'}[1]->nvalue($graph, $bindings, $bind);
    #print "self=" . DTAG::Interpreter::dumper($self) . "\n";
    #print "arg0=" . DTAG::Interpreter::dumper($arg0) . "\n";
    #print "val1=" . DTAG::Interpreter::dumper($val1) . "\n";
    #print "val2=" . DTAG::Interpreter::dumper($val2) . "\n";
	#print "$val1 < $val2\n";

	return defined($val1) && defined($val2) && ($val1 < $val2);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return "(" . ($self->utf8print() 
		? $args->[0]->pprint() . ($self->{'neg'} ? " ≥ " : " < ") . $args->[1]
		: $args->[0]->pprint() . ($self->{'neg'} ? " >= " : " < ") . $args->[1])
		. ")";
}
