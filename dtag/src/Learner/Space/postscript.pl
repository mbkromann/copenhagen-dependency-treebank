sub postscript {
	my $self = shift;

	# Find all terminal boxes in space
	my @terminals;
}

sub terminals {
	my $self = shift;
	my $terminals = shift || [];

	# Find terminals from all subspaces
	my @subspaces = @{$self->subspaces()};
	foreach my $subspace (@subspaces) {
		$subspace->terminals($terminals);
	}

	# This space is a terminal if it has no subspaces
	push @$terminals, $self
		if (! @subspaces);

	# Return terminals
	return $terminals;
}
