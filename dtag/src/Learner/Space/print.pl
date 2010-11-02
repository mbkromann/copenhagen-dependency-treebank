sub print {
	my $self = shift;
	my $indent = shift || 0;

	# Print self
	my $string = "\n" . (" " x $indent) 
		. "box=" . $self->print_box() 
		. " moved=" . $self->moved() 
		. "\n" . (" " x $indent)
		. "count=" . $self->count()
		. " weight=" . $self->weight() 
		. " phat=" . $self->phat() 
		. "\n" . (" " x $indent)
		. "rcount=" . $self->rcount()
		. " rweight=" . $self->rweight()
		. " rphat=" . $self->rphat() 
		. "\n" . (" " x $indent) 
		. "mass=" . ($self->weight() * $self->phat())
		. " rmass=" . ($self->rweight() * $self->rphat())
		. "\n";

	return $string;
}

sub print_all {
	my $self = shift;
	my $indent = shift || 0;
	my $string = $self->print($indent);

	# Print subspaces
	foreach my $subspace (@{$self->subspaces}) {
		$string .= $subspace->print_all($indent + 4);
	}

	return $string;
}

sub print_tree {
	my $self = shift;
	my $indent = shift || 0;
	my $string = (" " x $indent) 
		. $self->print_box() . ": "
		. sprintf(" w=%.4g wr=%.4g (c=%.4g ec=%.4g p=%.4g)", 
			$self->weight(),
			$self->rweight(), $self->count(),
			$self->pweight() * $self->phat() * $total,
			$self->pweight() * $self->pphat() * $total
		) . "\n";

	# Print subspaces
	foreach my $subspace (@{$self->subspaces}) {
		$string .= $subspace->print_tree($indent + 4);
	}

	return $string;
}

sub spaces {
	my $self = shift;
	my $spaces = shift || [];

	# Insert space itself on list
	push @$spaces, $self;

	# Insert all subspaces on list
	foreach my $subspace (@{$self->subspaces}) {
		$subspace->spaces($spaces);
	}

	# Return
	return $spaces;
}

sub print_sorted {
	my $self = shift;

	# Find all spaces contained in this space
	my $spaces = $self->spaces();

	# Sort spaces according to absolute moved probability mass
	my @sorted = sort {abs($b->moved()) <=> abs($a->moved())} @$spaces;

	# Print spaces
	my $string = "";
	foreach my $space (@sorted) {
		# Print space
		$string .= $space->print_split() . "\n";
	}

	# Return
	return $string;
}

sub print_splits {
	my $self = shift;
	my $indent = shift || 0;

	my $string = $self->print_split($indent) . "\n";

	# Print subspaces
	foreach my $subspace (@{$self->subspaces()}) {
		$string .= $subspace->print_splits($indent + 4);
	}

	# Return string
	return $string;
}

sub print_split {
	my $space = shift;
	my $indent = shift || 0;
	my $parent = $space->super();

	# Find position of space in parent
	my $pstring = "*";
	my $pos = "*";
	if ($parent) {
		$pstring = $parent->print_box();
		my @siblings = @{$parent->subspaces()};
		for ($pos = 0; $pos < $#siblings; ++$pos) {
			last() if ($siblings[$pos] == $space);
		}
		++$pos;
	}

	# Return string;
	my $istr = " " x $indent;
	return 
		$istr . $space->print_box() . " = $pstring" . "[$pos]\n"
			. $istr . sprintf("weight s=%.4g p=%.4g pr=%.4g.\n"
				. "$istr" . "count s=%.4g se=%.4g ss=%.4g sr=%.4g p=%.4g.\n"
				. "$istr" . "moved=%.4g. phat s=%.4g p=%.4g.\n",
				$space->weight() || 0, $space->pweight() || 1,
					$space->prweight() || 0,
				$space->count() || 0, 
					$space->pweight() * $space->phat() * $total,
					$space->weight() * $space->phat() * $total,
					$space->prweight() * $space->prphat() * $total,
					$space->pcount() || 0,
				$space->moved() || 0,
				$space->phat() || 0, $space->pphat() || 0);
}


sub print_box {
	my $self = shift;
	return "[" . join(", ", @{$self->box()}) . "]";
}

