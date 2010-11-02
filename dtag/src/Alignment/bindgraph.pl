sub bindgraph {
	my $self = shift;
	my $bindings = shift;
	my $key = shift || "G";
	my $graphs = $self->{'graphs'};
	foreach my $akey (keys(%$graphs)) {
		my $graph = $graphs->{$akey};
		$graph->bindgraph($bindings, "$key$akey")
	}
}
