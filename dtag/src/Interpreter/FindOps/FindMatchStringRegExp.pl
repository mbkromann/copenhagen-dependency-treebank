package FindMatchStringRegExp;
@FindMatchStringRegExp::ISA = qw(FindMatch);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $regexp = $self->{'args'}[0];
	return 0 if (! defined($regexp));
	return eval("\$string =~ $regexp")
}

sub pprint {
	my $self = shift;
	return $self->{'args'}[0];
}
