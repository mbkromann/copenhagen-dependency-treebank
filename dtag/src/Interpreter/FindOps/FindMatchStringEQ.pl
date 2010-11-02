package FindMatchStringEQ;
@FindMatchStringEQ::ISA = qw(FindMatch);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $pattern = $self->{'args'}[0];
	return $string eq $self->{'args'}[0];
}

sub pprint {
	my $self = shift;
	return '"' . $self->{'args'}[0] . '"';
}
