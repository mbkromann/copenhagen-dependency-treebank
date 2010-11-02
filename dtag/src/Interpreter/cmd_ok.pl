sub cmd_ok {
	my $self = shift;
	my $graph = shift;

	# Accept automatic alignment
	if (UNIVERSAL::isa($graph, 'DTAG::Alignment') && $graph->ok()) {
		$self->cmd_return($graph);
	} else {
		error("no learner associated with current graph");
	} 

	# Return
	return 1;
}
