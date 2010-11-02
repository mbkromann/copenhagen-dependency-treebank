package FindMatchStringIsa;
@FindMatchStringIsa::ISA = qw(FindMatch);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $typespec = $self->{'args'}[0];
	my $relset = $graph->relset($self->{'args'}[1]);
	return $typespec->match($graph, DTAG::Interpreter::strip_relation($string), $relset);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	my ($type, $relset) = @$args;
	return "isa(" . $type . 
		($relset ? ", $relset" : "") . ")";
}
