package FindADJ;
@FindADJ::ISA = qw(FindOp);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
	my $node1 = shift;
	my $node2 = shift;
	my $range = shift || [1,1];
	my $dir = shift || 1;

	# Find dmin and dmax
	my $dmin = 1e100;
	my $dmax = 0;
	foreach my $r (@$range) {
		$dmin = $r->[0] if ($dmin > $r->[0]);
		$dmax = $r->[1] if ($dmax < $r->[1]);
	}

	# Create object
    my $self = {'args' => [$node1, $node2, $range, $dir, $dmin, $dmax]};
    bless($self, $class);
    return $self;
}

sub next {
    my $self = shift;
    my $graph = shift;
    my $bindings = shift;
    my $bind = shift;
    my $U = shift;

    # Decline answer if constraint is negated
    return undef if ($self->{'neg'});

    # Constraint is unnegated, and there is exactly one unbound
    # variable U and bound variable B.
	my $Barg = ($U eq $self->{'args'}[0]) ? 1 : 0;
    my $B = $self->{'args'}[$Barg];
    my $Bval = $self->varbind($bindings, $bind, $B);
	my $dmax = $self->{'args'}[5];

    if ($bind->{$U} <= $Bval - $dmax) {
        $bind->{$U} = ($Bval - $dmax < 0 ? 0 : $Bval - $dmax);
        return 1;
    } elsif ($bind->{$U} <= $Bval + $dmax) {
		return 1;
	} else {
        return 0;
    }
}

sub vars {
	return [0,1];
}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	my $n0 = $self->varbind($bindings, $bind, $self->{'args'}[0]);
	my $n1 = $self->varbind($bindings, $bind, $self->{'args'}[1]);
	my $range = $self->{'args'}[2];

	my $dist = ($n1 - $n0) * ($self->{'args'}[3] || 1);
	foreach my $r (@$range) {
		my ($dmin, $dmax) = @$r;
		return 1 if ($dist >= $dmin && $dist <= $dmax);
	}
	return 0;
}


sub pprint {
	my $self = shift;
	my ($n0, $n1, $range, $dir) = @{$self->{'args'}};
	my $rangestr = join(",",
		map {$_->[0] == $_->[1] ? $_->[0] : $_->[0] . ".." . $_->[1]}
			@$range);
	$rangestr = "" if ($rangestr eq "1");
	return "(" . $n0
		. ($dir > 0 
			? " <" . $rangestr . "< "
			: " >" . $rangestr . "> ")
		. $n1 . ")";
}
