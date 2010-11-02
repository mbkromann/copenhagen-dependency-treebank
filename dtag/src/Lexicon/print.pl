sub print {
	my $string = "";

	# Print all types in the lexicon
	foreach my $type (sort(keys %{DTAG::LexInput->lexicon()->{'types'}})) {
		$string .= DTAG::LexInput->lexicon()->{'types'}{$type}->print() . "\n\n";
	}

	# Return
	return $string;
}
