sub varparse {
	my $self = shift;
	my $graph = shift;
	my $varstr = shift() . " ";
	my $varchk = shift || 0;
	my $hash = { };
	my ($var, $val);

	# Process variable specification
	while ($varstr) {
		# Read first variable-value pair
		if ($varstr =~ s/^\s*([^=\s]+)="`([^`]*)`"\s+//) {
			# Quoted-backquoted value
			($var, $val) = ($1, eval($2));
		} elsif ($varstr =~ s/^\s*([^=\s]+)=`([^`]*)`\s+//) {
			# Back-quoted value
			($var, $val) = ($1, eval($2));
		} elsif ($varstr =~ s/^\s*([^=\s]+)=(&22;)+(\S+?)(&22;)+\s+//) {
			# Quoted value
			($var, $val) = ($1, "$3");
		} elsif ($varstr =~ s/^\s*([^=\s]+)="([^"]*)"\s+//) {
			# Quoted value
			($var, $val) = ($1, "$2");
		} elsif ($varstr =~ s/^\s*([^=\s]+)=([^"]\S*)\s+//) {
			# Non-quoted value
			($var, $val) = ($1, $2);
		} elsif ($varstr =~ s/^\s*([^=\s]+)//) {
			# Variable name
			($var, $val) = ($1, undef);
		} elsif ($varstr =~ s/^\s+//) {
			# Blanks
			($var, $val) = (undef, undef);
		} else {
			# Syntax error: delete until next space
			$varstr =~ s/^\s*(\S+)\s*//;
			error($graph->size() .
				": not a variable-value pair: $1");
			($var, $val) = (undef, undef);
		}

		# Check that variable-value pair is defined
		if (defined($var)) {
			my $cvar = $varchk ? $graph->abbr2var($var) : $var;
			$cvar = 'input' if ($var eq 'input');
			if (defined($cvar)) {
				$hash->{$cvar} = $val;
			} else {
				error($graph->size() 
					. ": non-existent variable name: <$var>");
			}
		}
	}	

	# Return hash
	return $hash;
}

