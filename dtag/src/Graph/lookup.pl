=item $graph->lookup($time, $stream) = $lexemes

Return list of all lexemes starting at time $time in input stream
$stream.

=cut

sub lookup {
	my $self = shift;
	my $time = shift;
	my $stream = shift;

	# Find first node in graph with time0 >= $time, using binary
	# search (we assume nodes in the graph are ordered by increasing time0)
	my $imin = 0;
	my $imax = max(0, $self->size() - 1);
	while ($imin != $imax) {
		my $imid = int(($imin + $imax) / 2 - 0.25);	# round down
		my $time0 = $self->time0($imid);
		if ($time0 < $time) {
			$imin = min($imid + 1, $imax);
		} else {
			$imax = max($imid, $imin);
		} 
	}

	# Apply lexicon to all nodes with time0 = $time
	my $lexemes = [];
	my $node = $imin;
	my $nodeobj;
	while (defined($nodeobj = $self->node($node)) 
			&& $self->time0($node) == $time) {
		# Find node input, stream, and lexicon
		my $input = $nodeobj->input();
		my $nstream = $nodeobj->stream();

		# Process nodes from the right stream
		if ((! defined($stream)) || $nstream eq $stream) {	
			my $lexicon = $self->lexicon_stream($stream);

			# Fail if no lexicon
			if (! $lexicon) {
				DTAG::Interpreter::error("No lexicon specified in Graph->lookup"
					. " (node=$node)\n");
				last();
			}

			# Find all matching lexical entries
			my $list = $lexicon->lookup_word(lc($input));
			foreach my $typename (@$list) {
				my $lexeme = Lexeme->new();
				$lexeme->time0($self->time0($node));
				$lexeme->time1($self->time1($node));
				$lexeme->typename($typename);
				$lexeme->stream($nstream);
				push @$lexemes, $lexeme;
			}
		}

		# Look at next node
		++$node;
	}

	# Return found lexemes
	return $lexemes;
}
