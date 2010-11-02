sub train {
	my $self = shift;
	my $alignment = shift;
	my $weight = shift || 1;

	# Read off all edges from alignment file
	foreach my $e (@{$alignment->edges()}) {
		# Train with edge
		$self->train_edge($alignment, $e, $weight);
	}

	# Return
	return $self;
}
	

