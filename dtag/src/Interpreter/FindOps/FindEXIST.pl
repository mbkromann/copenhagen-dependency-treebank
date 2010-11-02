package FindEXIST;
@FindEXIST::ISA = qw(FindOp);

#sub new {
#}

sub match {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = shift;

	# Find variable and condition
	my $var = $self->varname();
	my $varkey = $self->varkey();
	my $keygraph = $graph->graph($varkey);
	my $cond = $self->{'args'}[1];
	my $oldval = $bind->{$var};
	my $neg = $self->{'neg'} ? 1 : 0;

	# Fix bindings in $bind and $bindings
	my $newbindings = {};
	my $newvarbindings = {};
	my $varbindings = $bindings->{'vars'};
	map {$newbindings->{$_} = $bindings->{$_}} keys(%$bindings);
	map {$newbindings->{$_} = $bind->{$_}} keys(%$bind);
	map {$newvarbindings->{$_} = $varbindings->{$_}}
		keys(%$varbindings);
	$newbindings->{'vars'} = $newvarbindings;
	delete $newbindings->{$var};

	# Find all solutions to $cond with $newbindings
	my $solutions = $cond->solve($keygraph, 0, $newbindings); 

	# Check number of solutions in $solutions
	return @$solutions;
}

sub unbound {
	my $self = shift;
	my $unbound = shift;

	# Find unbound variables in argument
	$self->{'args'}[1]->unbound($unbound);

	# Remove variable from 
	delete $unbound->{$self->varname()};

	# Return unbound variables
	return $unbound;
}

sub dnf {
	my $self = shift;
	my $var = $self->varname();
	my $neg = $self->{'neg'};

	# Return self if $self->{'dnf'} is set
	return FindOR->new(FindAND->new($self)) if ($self->{'dnf'});

	# Compute DNF of argument: FindOR(FindAND(...), ...)
	my $argdnf = $self->{'args'}[1]->dnf();

	# Process each disjunct
	my $new = $neg ? FindAND->new() : FindOR->new();
	foreach my $or (@{$argdnf->{'args'}}) {
		# Process each conjunct
		my @inner = ();
		my @outer = ();
		foreach my $and (@{$or->{'args'}}) {
			if (grep {$_ eq $var} keys(%{$and->unbound({})})) {
				push @inner, $and;
			} else {
				push @outer, ($neg ? $and->negate() : $and);
			}
		}

		# Resulting conjunct
		my $exist = FindEXIST->new([$var, $self->varkey()], 
			FindAND->new(@inner));
		$exist->{'dnf'} = 1;
		if ($neg) {
			# Operator: not exists
			$exist->{'neg'} = 1;
			push @{$new->{'args'}}, FindOR->new(@outer, $exist);
		} else {
			# Operator: exists
			push @{$new->{'args'}}, FindAND->new(@outer, $exist);
		}
	}

	# Return DNF of $new
	return $neg ? $new->dnf() : $new;
}

sub varname {
	my $self = shift;
	my $var = $self->{'args'}[0];
	return UNIVERSAL::isa($var, "ARRAY")
		? $var->[0] : $var;
}

sub varkey {
	my $self = shift;
	my $var = $self->{'args'}[0];
	return UNIVERSAL::isa($var, "ARRAY")
		? $var->[1] : "";
}

sub _pprint {
	my $self = shift;
	my $var = $self->varname();
	my $varkey = $self->varkey();
	my $arg = $self->{'args'}[1];
	return ($self->utf8print() ? "∃" : "EXIST") 
		. ($varkey ne "" ? $var . "@" . $varkey : $var)
		. $arg->pprint();
}
