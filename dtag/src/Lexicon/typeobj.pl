sub typeobj {
	my $arg = shift;

	if (ref($arg) && UNIVERSAL::isa($arg, "Type")) {
		return $arg;
	} elsif ($arg) {
		my $lexicon = DTAG::LexInput->lexicon();
		return $lexicon->get_type($arg) 
			|| $lexicon->{'ntypes'}{$arg};
	} else {
		return undef;
	}
}
