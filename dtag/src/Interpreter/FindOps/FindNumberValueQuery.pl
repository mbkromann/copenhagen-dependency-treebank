package FindNumberValueQuery;
@FindNumberValueQuery::ISA = qw(FindNumberValue);

use overload
    '""' => \& pprint;

sub unbound {
	my $self = shift;
	my $unbound = shift;
	$self->{'args'}[0]->unbound($unbound);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my $node = $args->[0];
	return "is(" . $self->{'args'}[0]->pprint() . ")";
}

sub nvalue {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	my $true = $self->{'args'}[0]->match($graph, $bindings, $bind);
	return $true ? 1 : 0;
}

