sub typespec {
	my $input = shift;
	my $obj1 = shift;
	
	# Left argument not provided
	if (! defined($obj1)) {
		my ($obj, $rest) = typespecl($input);
		if (!defined($obj)) {
			return (undef, $input);
		} elsif ($rest =~ /^([-+|].+)$/) {
			return typespec($1, $obj);
		} else {
			return ($obj, $rest);
		}
	}

	# Left argument provided
	else {
		# Input starts with binary operator "-+|"
		if ($input =~ /^([-+|])(.+)$/) {
			my $op = $1;
			my ($obj2, $rest2) = typespecl($2);
			return (defined($obj1) && defined($obj2))
				? typespec($rest2, 
					($op eq "+") 
						? TPlusOp->new($obj1, $obj2)
						: ($op eq "-") 
							? TMinusOp->new($obj1, $obj2)
							: TOrOp->new($obj1, $obj2))
				: (undef, $input);
		} else {
			return defined($obj1)
				? ($obj1, $input)
				: (undef, $input);
		}
	} 
}

sub typespecl {
	my $input = shift;

	# Input starts with "("
	if ($input =~ /^\((.+)$/) {
		my ($obj, $rest) = typespec($1);
		if ($rest =~ /^\)(.*)$/) {
			return ($obj, $1);
		} else {
			return (undef, $input);
		}
	}

	# Input starts with "-"
	elsif ($input =~ /^-(.+)$/) {
		my ($obj, $rest) = typespecl($1);
		return defined($obj) 
			? (TNegOp->new($obj), $rest)
			: (undef, $input);
	}

	# Input starts with ' or "
	elsif ($input =~ /^'([^']*)'(.*)$/) {
		return ($1, $2);
	} elsif ($input =~ /^"([^"]*)"(.*)$/) {
		return ($1, $2);
	}

	# Input is a type name
	elsif ($input =~ /^([^-+|)(]+)(.*)$/) {
		return ($1, $2);
	}

	# Faulty input
	else {
		return (undef, $input);
	}
}
