package FindTypeNot;
@FindTypeNot::ISA = qw(FindType);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $relset = shift;
	my $args = $self->{'args'};

	# Return the negation of $arg match
	return ! $args->[0]->match($graph, $string, $relset);
}

sub pprint {
	my $self = shift;
	my $args = $self->{'args'};
	return '(-' . $args->[0]->pprint() . ')';
}

