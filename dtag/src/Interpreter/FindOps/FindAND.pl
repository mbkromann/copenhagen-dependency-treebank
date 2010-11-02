package FindAND;
@FindAND::ISA = qw(FindOp);

sub negate {
	my $self = shift;
	return FindOR->new(map {$_->negate()} @{$self->{'args'}});
}

sub dnf {
	my $self = shift;

	# Compute DNFs of all arguments
	my @dnfs = map {$_->dnf()} @{$self->{'args'}};

	# Compute collective DNF by reducing AND(OR(X_i), Y1, ..., YN)
	# to OR_i DNF(AND(X_i,Y1,...,YN))
	my $dnf = shift(@dnfs)->{'args'};
	while(@dnfs) {
		# Find conjunctions in Ith DNF
		my $dnfI = shift(@dnfs)->{'args'};

		# Save all possible combinations of conjunctions in $dnf and
		# $dnfI in $dnfnew
		my $dnfnew = [];
		foreach my $and1 (@$dnf) {
			foreach my $andI (@$dnfI) {
				my @args = ();
				push @args, @{$and1->{'args'}};
				push @args, @{$andI->{'args'}};
				push @$dnfnew, FindAND->new(@args);
			}
		}
			
		# Replace $dnf by $dnfnew, and repeat the procedure
		$dnf = $dnfnew;
	}	

	# Return resulting DNF
	return FindOR->new(@$dnf);
}

sub solve {
	my $self = shift;
	my $graph = shift;
	my $maxsols = shift || 0;
	my $bindings = shift || {};
	my $solutions = shift || [];
	$graph->bindgraph($bindings);

	# Find list of all active constraints, ie, constraints with
	# uninstantiated variables
	my $args = $self->{'args'};
	my $active = {};
	my $asols = {};
	for (my $i = 0; $i < scalar(@$args); ++$i) {
		# Initialize search for condition
		my $cond = $args->[$i];
		$cond->find_init($bindings);

		if (keys(%{$cond->{'bind'}})) {
			# Find constraints with unbound variables
			$active->{$i} = 0;
			$asols->{$i} = [];
		} else {
			# Return if bindings have been falsified
			my $true = $cond->match($graph, $bindings, {});
			$true = $cond->{'neg'} ? (! $true) : $true;
			if (! $true) {
				# print "UNKNOWN ERROR!\n";
				return $solutions 
			}
		}
	}

	# Return if there are no active constraints
	if (! %$active) {
		# Add solution, if new, and return
		push @$solutions, $bindings;
		return $solutions;
	}

	# Find minimal active constraint, ie, active constraint with
	# minimal number of solutions
	my $incomplete = 1;
	my $minsols = 0;
	my $min;
	while ($incomplete) {
		# Find currently minimal active constraints
		my @mins = grep {$active->{$_} == $minsols} keys(%$active);
		$min = $mins[0];

		# Find new solution for currently minimal constraint
		my $newsol = $args->[$min]->find_next($graph, $bindings);
		if (! defined($newsol)) {
			$incomplete = 0;
		} else {
			# Save new partial solution
			push @{$asols->{$min}}, $newsol;

			# Update solution count and find new minimal count
			$active->{$min} += 1;
			++$minsols
				if (! grep {$active->{$_} == $minsols} keys(%$active));
		}
	}

	# Active constraint $min is minimal; solutions in $asols->{$min}
	foreach my $bind (@{$asols->{$min}}) {
		if (scalar(@$solutions) < $maxsols || ! $maxsols) {
			# Copy bindings array, and set new variable bindings
			my $newbindings = {};
			map {$newbindings->{$_} = $bindings->{$_}} (keys(%$bindings));
			map {$newbindings->{$_} = $bind->{$_}} (keys(%$bind));

			# Call solve recursively on new bindings
			$self->solve($graph, $maxsols, $newbindings, $solutions);
		}
	}

	# Return solutions
	return $solutions;
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
        return "(" . join($self->utf8print() ? " ∧ " : " & ",
            map {$_->pprint()} @$args) . ")";
    } else {
        return $args->[0]->pprint();
    }
}
