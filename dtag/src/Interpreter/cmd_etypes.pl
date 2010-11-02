sub cmd_etypes {
	my $self = shift;
	my $graph = shift;
	my $category = shift || "";
	my $types = shift || "";
	my $add = shift || "";

	# Copy default etypes to graph etypes, if no etypes for graph
	my $etypes1 = {};
	if ($category) {
		my $list = [];
		if ($add) {
			push @$list, @{$graph->etypes()->{$category}};
		}
		push @$list, split(/\s+/, $types);
		$etypes1->{$category} = $list;
	}
	$graph->etypes($etypes1);
	$self->{'etypes'} = $graph->etypes();

	# Print edges
	if (! $self->quiet()) {
		print "\n";
		my $etypes = $graph->etypes();
		foreach my $key (sort(keys %$etypes)) {
			print "EDGE CLASS $key: ", join(" ",
				sort(@{$etypes->{$key}})), "\n\n";
		}
	}

	# Return
	return 1;
}

