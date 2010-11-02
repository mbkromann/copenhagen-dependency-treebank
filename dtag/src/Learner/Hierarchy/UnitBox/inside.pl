sub inside {
	my $self = shift;
	my $subspace = shift;
	my $x = shift;

	# Determine whether $x lies in $subspace
	return $self->box_inside($self->space2box($subspace), $x);
}
