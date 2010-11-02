sub del_edge {
	my $self = shift;
	my $e = shift;

	# Delete edge from edge array
	my $edges = $self->edges();
	my $edge = $edges->[$e];
	splice(@$edges, $e, 1);

	# Delete keys
	my $outkey = $edge->outkey();
	my $inkey = $edge->inkey();
	foreach my $key (
			(map {$outkey . $_} @{$edge->outArray()}),
			(map {$inkey . $_} @{$edge->inArray()})) {
		$self->del_key($key, $edge);
	}

	# Delete crossings
	my $crossings = $self->var('crossings');
	my $edge_crossings = $crossings->{$edge};
	foreach my $e (@$edge_crossings) {
		$crossings->{$e} = [
			grep {$edge ne $_} @{$crossings->{$e}} ];
	}
	delete $crossings->{$edge};
} 
