sub value {
	my $self = shift;
	my $box = shift;

	# Check whether $box matches any of subspaces
	foreach my $subspace (@{$self->subspaces()}) {
		# Return weight calculated by first subspace that matches box
		return $subspace->value($box)
			if ($lexicon->intsct(
				$subspace->splittype(), 
				$box->[$subspace->splitdim()])); 
	}

	# No subspace matched: return default weight
	return $self->rweight();
}
