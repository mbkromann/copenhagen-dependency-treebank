sub is {
	my $type = shift;
	my $typespec = shift;
	my $lexicon = shift || DTAG::LexInput->lexicon();
	return $lexicon->isatype($type, $typespec);
}

