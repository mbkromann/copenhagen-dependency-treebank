sub cmd_view {
	my $self = shift;
	my $graph = shift;
	my $i1r = shift;
	my $i2r = shift;

	my $i1 = (! defined($i1r) || $i1r eq "") 
		? 0 
		: max($i1r + $graph->offset(), 0);
	my $i2 = defined($i2r) 
		? $i2r + $graph->offset() 
		: $graph->size()-1;
	$i2 = min($i2, $graph->size()-1);
	
	Node->use_color(1) if (! $self->quiet());

	# Print nodes
	for (my $i = $i1; $i <= $i2; ++$i) {
		print print_node($graph, $i);

		# Abort if requested
		return 1 if ($self->abort());
	}	

	Node->use_color(0);
	return 1;
}

sub print_node {
	my $graph = shift;
	my $pos = shift;
	my $N = $graph->node($pos);

	my $rpos = $pos - $graph->offset();

	return (($graph->offset() && $rpos >= 0) ? "+$rpos" : "$rpos") 
		. ($N->comment() ? "| " : ": ")
		. $N->xml($graph, 0, 1) . "\n";
}

sub min {
	my $min = shift;
	foreach my $e (@_) {
		$min = $e if (0+$e < $min);
	}
	return $min;
}

sub max {
	my $max = shift;
	foreach my $e (@_) {
		$max = $e if (0+$e > $max);
	}
	return $max;
}
			
