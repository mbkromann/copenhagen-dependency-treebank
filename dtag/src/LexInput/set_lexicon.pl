sub set_lexicon {
	my $self = shift;
	my $lex = shift;

	if (ref($lex) && UNIVERSAL::isa($lex, 'DTAG::Lexicon')) {
		$lexicon = $lex;
	} else {
		print "Illegal lexicon: $lex\n";
	}
	return $lexicon;
}
