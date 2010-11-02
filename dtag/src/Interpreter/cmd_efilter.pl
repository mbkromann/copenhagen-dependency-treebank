sub cmd_efilter {
	my $self = shift;
	my $graph = shift;
	my $filter = " " . (shift || "");

	# Check that graph is a graph
	if (! UNIVERSAL::isa($graph, 'DTAG::Graph')) {
		error("this command can only be applied to graphs");
		return 1;
	}

	# Unpack filter
	my $default_remove = 0;
	$default_remove = 1 
		if ($filter =~ /\s+\+/ && $filter !~ /\s+-/);
	my $keep = {};
	my $remove = {};
	foreach my $spec (split(/\s+/, $filter)) {
		if ($spec) {
			print "spec: <$spec>\n";
			my $op = substr($spec, 0, 1);
			my $label = substr($spec, 1);
			if ($op eq "+") {
				$keep->{$label} = 1;
			} elsif ($op eq "-") {
				$remove->{$label} = 1;
			}
		}
	}

	# Save default action
	if (! $keep->{""} && ! $remove->{""}) {
		$keep->{""} = 1 if (! $default_remove);
		$remove->{""} = 1 if ($default_remove);
	}

	# Process all edges in the graph
	$graph->do_edges(\&efilter_edge, $graph, $keep, $remove);
	        
	# Return
	return 1;
}

sub efilter_edge {
	my $e = shift;
	my $graph = shift;
	my $keep = shift;
	my $remove = shift;
	my $label = $e->type();

	# Remove edge if it is on remove list and not on keep list
	if (! $keep->{$label} && ($remove->{$label} || $remove->{""})) {
		$graph->edge_del($e);
	}
}
	


