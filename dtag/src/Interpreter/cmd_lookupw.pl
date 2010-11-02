sub cmd_lookupw {
	my $self = shift;
	my $graph = shift;
	my $input = shift;

	my $lexicon = $self->lexicon();
	my @types = @{$lexicon->lookup_word(lc($input))};
	print "input = $input\n" . "matches = " . join(" ", @types) . "\n";
}


