sub lookup_words {
	my $self = shift;
	my $outwords = shift;
	my $inwords = shift;

	# print "lookup_words: " . DTAG::Interpreter::dumper($inwords, $outwords) . "\n";

	# Save hash
	my $hash = { };

	# Lookup in-words
	foreach my $inword (@$inwords) {
		foreach my $alex (@{$self->lookup_in($inword)}) {
			$hash->{$alex->string()} = $alex;
		}
	}

	# Lookup out-words
	foreach my $outword (@$outwords) {
		foreach my $alex (@{$self->lookup_out($outword)}) {
			$hash->{$alex->string()} = $alex;
		}
	}

	# Return all alexes
	return [ values(%$hash) ];
}
	
