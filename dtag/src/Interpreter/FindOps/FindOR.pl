package FindOR;
@FindOR::ISA = qw(FindOp);

sub negate {
	my $self = shift;
	return FindAND->new(map {$_->negate()} @{$self->{'args'}});
}

sub dnf {
	my $self = shift;

	# Find DNF of arguments
	my @dnfs = map {$_->dnf()} @{$self->{'args'}};

	# Reduce DNFs to one big DNF
	my @ands = ();
	foreach my $dnf (@dnfs) {
		push @ands, @{$dnf->{'args'}};
	}

	# Return DNF of entire structure
	return FindOR->new(@ands);
}

sub unbound {
	my $self = shift;
	my $unbound = shift;

	# For each argument, mark all unbound variables in hash $unbound
	foreach my $and (@{$self->{'args'}}) {
		$and->unbound($unbound);
	}

	# Return
	return $unbound;
}

sub _pprint {
	my $self = shift;
	my $args = $self->{'args'};
	if (scalar(@$args) > 1) {
		return "(" . join($self->utf8print() ? " ∨ " : " | ",
        	map {$_->pprint()} @$args) . ")";
	} else {
		return $args->[0]->pprint();
	}	
}

