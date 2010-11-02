package FindTypePlus;
@FindTypePlus::ISA = qw(FindType);

use overload
    '""' => \& print;

sub match {
	my $self = shift;
	my $graph = shift;
	my $string = shift;
	my $relset = shift;
	my $args = $self->{'args'};

	# Return 0 if any arg fails to match, otherwise 1
	foreach my $arg (@$args) {
		return 0
			if (! $arg->match($graph, $string, $relset));
	}
	return 1;
}

sub pprint {
    my $self = shift;
    my $args = $self->{'args'};
    return "(" . join("+", map {$_->pprint()} @$args) . ")";
}

