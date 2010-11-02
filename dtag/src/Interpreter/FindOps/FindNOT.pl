package FindNOT;
@FindNOT::ISA = qw(FindOp);

sub negate {
	# Negate NOT(X) by returning X
	my $self = shift;
	return $self->{'args'}[0];
}

sub dnf {
	my $self = shift;
	my $arg = $self->{'args'}[0];

	# Reduce argument by propagating negation downwards to terminal operators
	my $reduced = $arg->negate();

	# Return DNF for reduced argument
	return $reduced->dnf();
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

