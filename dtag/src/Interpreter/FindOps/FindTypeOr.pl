package FindTypeOr;
@FindTypeOr::ISA = qw(FindType);

use overload
    '""' => \& print;

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $relset = shift;
	my $args = $self->{'args'};

	# Return 1 if any arg matches, otherwise 0
	foreach my $arg (@$args) {
		return 1
			if ($arg->match($graph, $string, $relset));
	}
	return 0;
}

sub pprint {
    my $self = shift;
    my $args = $self->{'args'};
    return "(" . join("|", map {$_->pprint()} @$args) . ")";
}

