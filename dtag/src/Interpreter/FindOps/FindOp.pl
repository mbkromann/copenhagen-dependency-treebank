package FindOp;
@FindOp::ISA = qw(FindProc);

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    # Arguments
    my $self = {'args' => [@_]};
    bless($self, $class);
    return $self;
}

sub clone {
	my $self = shift;
	my $clone = { 'args' => [@{$self->{'args'}}] };
	$clone->{'neg'} = $self->{'neg'} if ($self->{'neg'});
	bless($clone, ref($self));
	return $clone;
}


##
## Searching
##

sub negate {
	my $self = shift;
	my $clone = $self->clone();
	$clone->{'neg'} = $self->{'neg'} ? 0 : 1;
	return $clone;
}

sub setNegated {
	my $self = shift;
	$self->{'neg'} = 1;
	return $self;
}

sub dnf {
	my $self = shift;
	return FindOR->new(FindAND->new($self->clone())); 
}

sub find_init {
    my $self = shift;
    my $bindings = shift;
	my $args = $self->{'args'};

    # Find unbound variables
    my $bind = $self->{'bind'} = {};
	my @vars = grep {! defined($bindings->{$_})} keys(%{$self->unbound({})});
    map {$bind->{$_} = 0} @vars;

	# Set done flag to false
	$self->{'done'} = 0;
}

sub find_next {
	my $self = shift;
	my $graph = shift;
	my $bindings = shift;
	my $bind = $self->{'bind'};
	my @vars = sort(keys(%$bind));

	# Return if constraint has terminated, or graph size is zero
	return undef if ($self->{'done'} || $#vars == -1);

	# Loop through all possible variable bindings
	my $result = {};
	while(1) {
	    #print "FO: " . join(" ", map {$_ . "=" . $bind->{$_}} keys(%$bind)) .  "\n";

		# Find first solution that does not precede current bindings
		my $bound = 0;
		while (! $bound) {
			# Find first legal binding that does not precede current
			# binding in the ordering
			for (my $v = $#vars; $v >= 0; --$v) {
				if ($bind->{$vars[$v]} >= $self->graphsize($graph, $bindings, $vars[$v])) {
					# Overflow in variable $v
					$bind->{$vars[$v]} = 0;

					# Carry overflow to next variable, or fail
					if ($v != 0) {
						# Increment variable $v-1
						$bind->{$vars[$v-1]} += 1;
					} else {
						# Overflow in last variable
						$self->{'done'} = 1;
						return undef;
					}
				} else {
					# No overflow
					last();
				}
			}

			# Let custom binder perform binding on last variable:
			# custom binder "next" returns "undef" if it doesn't know
			# a better binding than brute-force, 0 if it cannot find
			# other bindings of the current free variable, and 1 if it
			# found a possible candidate for binding.
			$bound = 1;
			my $next = $self->next($graph, $bindings, $bind, @vars);
			if (defined($next) && $next == 0) {
				# Custom binder exhausted all bindings of last variable
				$bind->{$vars[$#vars]} = $self->graphsize($graph, $bindings, $vars[$#vars]);
				$bound = 0;
			} 
		}

		# Return undef if we have exhausted all bindings
		if ($bind->{$vars[0]} >= $self->graphsize($graph, $bindings, $vars[0])) {
			$self->{'done'} = 1;
			return undef;
		}

		# Check whether the variable binding satisfies the constraint,
		# and exit if we have a match
		my $match = $self->match($graph, $bindings, $bind);	
		$match = $self->{'neg'} ? (! $match) : $match;
		if ($match) {
			# Copy local bindings, increment local bindings, and exit
			map {$result->{$_} = $bind->{$_}} keys(%$bind);
			$bind->{$vars[$#vars]} += 1;
			return $result;
		} else {
			# Increment local bindings, then continue searching
			$bind->{$vars[$#vars]} += 1;
		}
	}
}

##
## Dummy procedures: should be defined by subclasses
## 

sub solve {
	return [];
}

sub next {
	# Return undefined by default
	return undef;
}

sub match {
	# Return undefined by default
	return undef;
}

sub vars {
	# Return no variables by default
	return [];
}

sub unbound {
	# Return all unbound variables in simple constraint: this must be
	# overridden for complex constraints like FindAND, FindOR,
	# FindEXIST
	my $self = shift;
	my $unbound = shift;

	# Mark all unbound variables in hash $unbound
	map {$unbound->{$self->{'args'}[$_]} = 1} @{$self->vars()};

	# Return
	return $unbound;
}

sub graphsize {
	my ($self, $graph, $bindings, $var) = @_;
	my $key = $self->varkey($bindings, $var);
	my $keygraph = $graph->graph($key);
	if (! defined($keygraph)) {
		DTAG::Interpreter::warning("Could not find graph for key " . ($key || "undef") .  "\n");
		return 0;
	}
	return $keygraph->size();
}

