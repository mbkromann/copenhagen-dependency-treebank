sub ok {
	my $self = shift;
	my $alignment = shift;
	
	# Find stored boundaries for last autoalign
	my $boundaries = $alignment->var('autoalign');
	if (! $boundaries) {
		DTAG::Interpreter::error("no automatically created alignment edges");
		return 0;
	}
	my ($outkey, $o1, $o2, $inkey, $i1, $i2) = @$boundaries;

	# Modify creator in autoaligned edges
	foreach my $edge (@{$alignment->edges()}) {
		# Skip if edge is outside current boundaries
		next() if (! $alignment->edge_in_autowindow($edge));

		# Change label from " ! " to ""
		$edge->type("") if ($edge->type() eq " ! ");

		# Change creator
		$edge->creator(-1) if ($edge->creator() <= -100);
	}

	# Retrain lexicon
	$self->untrain();
	$self->train($alignment);

	# Return success
	return 1;
}



