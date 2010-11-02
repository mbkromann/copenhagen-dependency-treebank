sub cmd_load_closegraph {
	my $self = shift;
	my $graph = shift;

	# Close current graph, if unmodified
	if (! $graph->mtime()) {
		$self->{'graphs'} = [grep {$_ != $graph} @{$self->{'graphs'}}];
	}
}

