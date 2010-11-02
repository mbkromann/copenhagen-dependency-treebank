sub path {
	my $self = shift;
	my $path = shift;

	# Return space if path is empty
	return $self if (! @$path);
	
	# Go to child path
	my $child = shift(@$path);
	my $subspaces = $self->subspaces();
	my $subspace = $subspaces->[$child-1];
	return $subspace->path($path);
}


