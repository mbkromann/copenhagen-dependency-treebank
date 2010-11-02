package FindStringRegExp;
@FindStringRegExp::ISA = qw(FindOp);

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$self->{'args'}[1]->unbound($unbound);
	return $unbound;
}   
					    
sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Variables
	my $val = $self->{'args'}[1]->svalue($graph, $bindings, $bind);
	my $regexp = $self->{'args'}[0];

	# Check existence of node and return result
	return 0 if (! (defined($val)  && defined($regexp)));
	return eval("\$val =~ $regexp") ? 1 : 0;
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return $args->[1]->pprint() . " =~ " . $args->[0];
}
