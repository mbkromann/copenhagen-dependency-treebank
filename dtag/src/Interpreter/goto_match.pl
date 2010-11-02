sub goto_match {
	my $self = shift;
	my $match = shift;

	# Find file and binding, and exit if non-existent
	$match = max(1, $match);
	my ($file, $binding) = $self->mid2mspec($match);
	if (! $file) {
		error("Non-existent match: $match");
		return ;
	}

	# Find graph
	$self->{'match'} = $match;
	my $graph = $self->graph();
	if (! ($graph && ($graph->file() || "") eq $file)) {
		$self->cmd_load($graph, undef, $file);
		$graph = $self->graph();
	}

	# Find position of first node in $binding
	my $min = 1e100;
	grep {
		my $v = $binding->{$_};
		$min = $v if (defined($v) && $v =~ /^[0-9]+$/ && $v < $min);
	} keys(%$binding);

	# Goto this position
	if (UNIVERSAL::isa($graph, "DTAG::Graph")) {
		$self->cmd_show($graph, $min - $self->var('goto_context'), "", $min);
	} elsif (UNIVERSAL::isa($graph, "DTAG::Alignment")) {
		$self->cmd_show_align($graph, 0);
	}

	# Print new match
	print $self->print_match($self->{'match'}, $file, $binding)
		unless ($self->quiet());

	# Return
	return;
}
