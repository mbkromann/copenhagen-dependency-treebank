# $lexicon->phon_split($phon1, ..., $phon1): (\@stemtrans, \@root)

sub phon_split {
	my $lexicon = shift;
	my $phonsub = $lexicon->{'phonsub'};

	# Strings
	my @strans = ();
	my @root = ();

	# Process phonetic operations
	while (@_) {
		# Read next operation
		my $op = shift;

		# Rewrite operator by phonetic operator resolution
		my $newop = $phonsub->{$op} || $op;

		# Process phonetic operator
		if (UNIVERSAL::isa($newop, 'CODE') || $newop =~ /s\/.*\/.*\//) {
			# Stem transformation
			push @strans, $op;
		} else {
			unshift @_, $op;
			last;
		}
	}

	# Return result
	return ([@strans], [@_]);
}
