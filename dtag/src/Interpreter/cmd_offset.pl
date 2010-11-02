sub cmd_offset {
	my $self = shift;
	my $graph = shift;
	my $sign = shift || "+";
	my $number = shift || "0";

	if ($number eq "end") {
		$number = $graph->size();
	}

	# Set new offset
	if ($sign eq "+") {
		$graph->offset($graph->offset() + $number);
	} elsif ($sign eq "-") {
		$graph->offset($graph->offset() - $number);
	} elsif ($sign eq "=") {
		$graph->offset($number);
	}

	# Report offset
	print "Offset: " . $graph->offset() . "\n" if (! $self->quiet());

	# Return with success
	return 1;
}

sub pos2apos {
	my $graph = shift;
	my $pos = shift;

	# Decompose position
	$pos =~ /^([+-=])?([0-9]+)$/;

	# Calculate absolute position
	if ($1 eq "+") {
		return $graph->offset() + $2;
	} elsif ($1 eq "-") {
		return $graph->offset() - $2;
	} elsif ($1 eq "=") {
		return $2;
	}
}	
