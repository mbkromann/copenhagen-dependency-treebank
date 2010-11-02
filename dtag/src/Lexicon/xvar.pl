# ($valtype, $value) = $lexicon->xvar($types, $var, $valtype, $value, $mark)

sub xvar {
	my $self = shift;
	my $types = shift;
	my $var = shift;
	my $typename;

	# Examine whether $types is a single type or a type chain
	my $type;
	my $chain = [];
	if (UNIVERSAL::isa($types, 'ARRAY')) {
		$types = [@$types];
		$typename = pop(@$types);
		$type = typeobj($typename);
		$chain = $types;
	} else {
		$typename = $types;
		$type = typeobj($typename);
	}

	# Find $valtype and $value
	my $valtype = @_ ? ((~ 8) & shift) : 0;
	my $value = @_ ? shift : undef;
	my $mark = @_ ? shift : $self->newmark();

	# Exit if type does not exist
	if (! $type) {
		return ($valtype, $value);
	}

	# Exit if type already has mark, or update mark
	if ($self->mark($type) == $mark) {
		return ($valtype, $value);
	} else {
		$self->mark($type, $mark);
	}

	# Retrieve local value
	my $lvaltype = 0;
	my $lvalue = $type->lvar($var);
	my $inherit = 1;
	if (defined $lvalue) {
		if (! (ref($lvalue) && UNIVERSAL::isa($lvalue, "ValOp"))) {
			$lvaltype = 1;
		} elsif ($lvalue->isa("ListVal")) {
			$lvaltype = 2;
		} elsif ($lvalue->isa("SetVal")) {
			$lvaltype = 3;
		} elsif ($lvalue->isa("HashVal")) {
			$lvaltype = 4;
		}

		# Exit if local value is of wrong type
		if ((($valtype & 7) != ($lvaltype & 7)) && (($valtype & 7) != 0)) {
			warn("Warning: inheritance type mismatch in variable $var of type " 
				. $type->get_name());
			return ($valtype, $value);
		} 

		# Update inheritance information, if $lvalue is VarOp
		if ($lvaltype > 1) {
			$inherit = $lvalue->inherit();
			$lvaltype |= ($inherit & 2) ? 32 : 16;
			$inherit &= 1;
		} else {
			$inherit = 0;
		}

		# Update $valtype if $lvaltype is more specific
		$valtype |= ($lvaltype & 7) if (! ($valtype & 7));
		$valtype |= 8;
		$valtype |= ($lvaltype & 48) if (! ($valtype & 48));
	}

	# Local atomic value: return result
	if (($lvaltype & 7) == 1) {
		return ($valtype, $lvalue);
	} 

	# Local complex value: initial update with local value
	if (($lvaltype & 7) > 1) {
		$value = $lvalue->preset($value);
	}

	# Call super types until value defined, if inheritance is on
	my $svaltype = $lvaltype || $valtype;
	if ($inherit) {
		# Find immediate super types
		#my @super = @{$type->get_super()};
		my @super = reverse(@{$type->get_super()});
		if (@$chain) {
			push @super, $chain;
		}

		# Process immediate super types
		foreach my $s (@super) {
			# Skip processing if we have singular inheritance where
			# super has just changed value, or if atomic value returned
			last if (($svaltype & 8) && ((($svaltype & 7) == 1) || 
				($svaltype & 16)));

			# Find super value
			($svaltype, $value) = $self->xvar($s, $var, $svaltype, $value, 
				$mark);

			# Update $valtype if $svaltype is more specific
			$valtype |= ($svaltype & 7) if (! ($valtype & 7));
			$valtype |= ($svaltype & 8);
			$valtype |= ($svaltype & 48) if (! ($valtype & 48));
		
		}
	}

	# Final update with local value
	if (($lvaltype & 7) > 1) {
		$value = $lvalue->postset($value);
	}

	# Return
	return ($valtype, $value);
}


