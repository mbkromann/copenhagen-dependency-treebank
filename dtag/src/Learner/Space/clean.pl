sub clean {
	my $self = shift;

	# Delete data
	$self->data([]);

	# Continue recursively with all subspaces
	foreach my $subspace (@{$self->subspaces()}) {
		$subspace->clean();
	}
}
