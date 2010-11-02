sub add_edge {
	my $self = shift;
	my $edge = shift;

	# Add edge to list of edges
	push @{$self->{'edges'}}, $edge;

	# Index edges by nodes
	my $outkey = $edge->outkey();
	my $inkey = $edge->inkey();
	foreach my $key (
			(map {$outkey . $_} @{$edge->outArray()}),
			(map {$inkey . $_} @{$edge->inArray()})) {
		$self->add_key($key, $edge);
	}

	# Find all crossing edges
	my $edge_crossings = $self->new_crossings($edge);
	my $crossings = $self->var('crossings');
	$crossings->{$edge} = $edge_crossings;
	foreach my $e (@$edge_crossings) {
		push @{$crossings->{$e}}, $edge;
	}

	# Find all creator=-101 edges coincident with this edge, and delete them
	my $deledges = {};
	foreach my $n (@{$edge->inArray()}) {
		map {$deledges->{$_} = $_} @{$self->node_edges($inkey, $n)};
	}
	foreach my $n (@{$edge->outArray()}) {
		map {$deledges->{$_} = $_} @{$self->node_edges($outkey, $n)};
	}
	foreach my $e (sort {$b <=> $a} values(%$deledges)) {
		# print "deledge=" . (defined($e) ? $e : "undef") . 
			" " . (defined($self->edge($e)) 
				?  $self->edge($e)->string() : "undef") . "\n";
		$self->del_edge($e)
			if ($self->edge($e) ne $edge && 
				$self->edge($e)->creator() <= -100);
	}

	# Return
	return $edge;
} 
