package FindStringEQ;
@FindStringEQ::ISA = qw(FindOp);

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

	my $val1 = $self->{'args'}[0]->svalue($graph, $bindings, $bind);
	my $val2 = $self->{'args'}[1]->svalue($graph, $bindings, $bind);
	return defined($val1) && defined($val2) && ($val1 eq $val2);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'}; return "(" 
		. $args->[0]->pprint() . ($self->{'neg'} ? " ne " : " eq ") 
		. $args->[1]->pprint() . ")";
}
