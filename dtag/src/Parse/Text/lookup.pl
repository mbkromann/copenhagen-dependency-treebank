=item $text->lookup($time, $stream) = $lexemes

Return list of all lexemes starting at time $time in stream $stream.

=cut

sub lookup {
	my $self = shift;
	my $time = shift;
	my $stream = shift;

	# Find streams
	my $streams = defined($stream) ?  [$stream] : $self->streams();

	# Find substring of input starting at time $time
	my $lexemes = [];
	foreach $stream (@$streams) {
		my $text = substr($self->input($stream) || "", $time, $LEXEME_MAXLEN);
		my $lexicon = $self->lexicon_stream($stream);
		if (! $lexicon) {
			DTAG::Interpreter::error("No lexicon specified in Text->lookup");
			return [];
		}

		# Apply lexicon to all nodes with time0 = $time
		my $list = $lexicon->lookup(lc($text));
		foreach my $pair (@$list) {
			my $lexeme = Lexeme->new();
			$lexeme->time0($time);
			$lexeme->time1($time + length($pair->[0]));
			$lexeme->input($pair->[0]);
			$lexeme->typename($pair->[1]);
			$lexeme->stream($stream);
			push @$lexemes, $lexeme;
		}
	}

	# Return found lexemes
	return $lexemes;
}
