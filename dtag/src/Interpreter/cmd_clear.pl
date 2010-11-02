sub cmd_clear {
	my $self = shift;
	my $graph = shift;
	my $type = shift || '-tag';

	if ($type eq '-lex') {
		my $lexicon = $self->lexicon();
		return 1 if (! $lexicon);
		$lexicon->clear();
	} elsif ($type eq '-edges') {
		if (UNIVERSAL::isa($graph, 'DTAG::Graph')) {
			$graph->clear_edges();
		} elsif (UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
			$graph->erase_all();
		}
	} else {
		if (UNIVERSAL::isa($graph, 'DTAG::Graph')) {
			$graph->clear();
			$graph->file('');
			$self->cmd_return($graph);
		} elsif (UNIVERSAL::isa($graph, 'DTAG::Alignment')) {
			$graph->erase_all();
			$graph->file('');
			$self->cmd_return($graph);
		}
	} 

	return 1;
}
