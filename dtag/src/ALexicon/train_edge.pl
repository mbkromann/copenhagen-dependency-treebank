sub train_edge {
	my $self = shift;
	my $alignment = shift;
	my $edge = shift;
	my $weight = shift || 1;

	# Compute in and out pattern, and count number of gaps
	my ($outpattern, $outgaps) = 
		$self->nodes2pattern($alignment, $edge->outkey(), $edge->outArray()); 
	my ($inpattern, $ingaps) = 
		$self->nodes2pattern($alignment, $edge->inkey(), $edge->inArray()); 

	# Store alex entry and observed number of gaps
	$self->add_alex($outpattern, $edge->type(), $inpattern, $weight);
	$self->add_gaps('out', $outgaps);
	$self->add_gaps('in', $ingaps);
}

