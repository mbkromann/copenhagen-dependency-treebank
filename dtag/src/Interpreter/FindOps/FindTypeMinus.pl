package FindTypeMinus;
@FindTypeMinus::ISA = qw(FindType);

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $relset = shift;
	my $args = $self->{'args'};

	# Return 1 if any arg matches, otherwise 0
	return 0 if (! $args->[0]->match($graph, $string, $relset));
	for (my $i = 1; $i <= $#$args; ++$i) {
		return 0 if ($args->[$i]->match($graph, $string, $relset));
	}
	return 1;
}

sub pprint {
    my $self = shift;
    my $args = $self->{'args'};
    return "(" . join("-", map {$_->pprint()} @$args) . ")";
}

