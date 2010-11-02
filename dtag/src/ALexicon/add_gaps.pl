sub add_gaps {
	my $self = shift;
	my $type = shift;
	my $gaps = shift;
	my $count = shift || 1;

	# Process gaps
	my $gaplist = $self->gaps($type);
	foreach my $gap (@$gaps) {
		$gaplist->[$gap] = ($gaplist->[$gap] || 0) + $count;
	}

	# Update total number of gaps
	$self->var('total_gaps', 
		($self->var('total_gaps') || 0) + scalar(@$gaps));
}
