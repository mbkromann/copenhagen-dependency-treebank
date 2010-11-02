sub cmd_goto {
	my $self = shift;
	my $graph = shift;
	my $cmd = shift || 0;
	my $mod = shift;

	if ($cmd =~ s/^-context\s+([0-9]+)\s*//) {
		# Set goto context size
		$self->var('goto_context', $1 || 0);
	} elsif ($cmd =~ /^\s*[GA]([0-9]+)\s*$/) {
		# Goto graph specified by graph index
		$self->goto_graph($1 - 1);
	} elsif ($cmd =~ /^\s*([GA]\[[0-9]+\])\s*$/) {
		# Goto graph specified by graph id
		$self->cmd_load($graph, undef, $1);
	} elsif ($cmd =~ /^\s*G([0-9]+):([0-9]+)\s*$/) {
		# Goto graph specified by graph id and node id
		$self->goto_graph($1 - 1);
		$self->cmd_show($self->graph(), $2);
	} elsif ($cmd =~ /^\s*(next\s*[gG]||[gG]\+)\s*$/) {
		# Goto next graph
		$self->goto_graph($self->{'graph'} + 1);
	} elsif ($cmd =~ /^\s*(prev\s*[gG]|[gG]-)\s*$/) {
		# Goto previous graph
		$self->goto_graph($self->{'graph'} - 1);
	} elsif ($cmd =~ /^\s*M([0-9]+)\s*$/) {
		# Goto match specified by match id
		$self->goto_match($1);
	} elsif ($cmd =~ /^\s*(next\s*[mM]?|[mM]\+)\s*$/) {
		# Goto next match
		$self->goto_match(($self->{'match'} || 0) + 1);
	} elsif ($cmd =~ /^\s*(prev\s*[mM]?|[mM]-)\s*$/) {
		# Goto previous match
		$self->goto_match(($self->{'match'} || 0) - 1);
	} else {
		# Unknown goto command
		print "goto: unknown command $cmd\n";
	}

	# Return
	return 1;
}
