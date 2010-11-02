# $lexicon->phon2str($phon1, ..., $phon1): $string

sub phon2str {
	my $lexicon = shift;
	my $phonsub = $lexicon->{'phonsub'};

	# Strings
	my @strs  = ();
	my $str   = '';		# read-write string

	# Process phonetic operations
	while (@_) {
		# Read next operation
		my $op = shift;

		# Rewrite operator by phonetic operator resolution
		my $newop = $phonsub->{$op};
		$op = $newop if (UNIVERSAL::isa($newop, 'CODE'));

		# Process phonetic operator
		if (UNIVERSAL::isa($op, 'CODE')) {
			$str = &$op($str);
		} elsif ($op =~ /s\/.*\/.*\//) {
			# Replacement-transformation
			eval('$str =~ ' . $op);
		} else {
			push @strs, $str;
			$str = $op;
		}
	}
	push @strs, $str;

	# Return result
	return join('', @strs);
}
